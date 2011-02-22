class Terryblr::Photo < Terryblr::Base

  #
  # Constants
  #
  
  #
  # Behaviours
  #
  serialize :sizes
  
  # Regen thumbs with rake paperclip:refresh CLASS=Photo or .reprocess!
  has_attached_file :image,
    :styles => Terryblr::Settings.photo_dimensions.dup.symbolize_keys,
    :storage => Terryblr::Settings.key?('s3') ? :s3 : :filesystem,
    :convert_options => { :all=> "-density 72 " },
    :path => Terryblr::Settings.key?('s3') ? ":attachment/:id/:style.:extension" : ":rails_root/public/system/:attachment/:id/:style/:basename.:extension",
    :s3_credentials => (Terryblr::Settings.s3.symbolize_keys rescue nil),
    :bucket => [Terryblr::Settings.app_name, Rails.env].join('-').parameterize.to_s,
    :log_command => Rails.env.development?

  #
  # Callbacks
  #

  #
  # Associatons
  #
  belongs_to :photoable, :polymorphic => true
  has_many :features, :class_name => "Terryblr::Feature"

  #
  # Validations
  #
  validates_presence_of :image_file_name, :unless => :url? 
  validates_presence_of :url, :unless => :image_file_name?
  validates_url_format_of :url, :if => :url?

  #
  # Scopes
  #
  default_scope :order => "display_order asc, id desc" 

  #
  # Class Methods
  #
  class << self
  end

  #
  # Instance Methods
  #
  before_validation :fetch_remote_image
  before_create :add_to_queue
  after_save :update_associated_models
  
  def fetch_remote_image
    # If there is a URL then download it and use
    self.image = do_download_remote_image if url_changed?
  end

  def add_to_queue
    # Set the display order to be last
    self.display_order = Photo.count(:conditions => {:photoable_id => self.photoable_id, :photoable_type => self.photoable_type})
  end

  def update_associated_models
    # Update assoc'd models
    photoable.soft_touch(:updated_at, false) if photoable and !photoable.new_record?
    features.update_all({:updated_at => Time.now.in_time_zone})
  end

  def size(thumb)
    sizes[thumb.to_sym]
  rescue => exception
    logger.error { "Error getting image sizes: #{exception}" }
    {}
  end

  # Overload Paperclip so that images are only resaved when it changes - uses too much memory otherwise
  def save_attached_files
    super if image_file_size_changed?
  end

  # Save the images dimensions before being sent to storage
  after_post_process :calculate_attachment_sizes
  def calculate_attachment_sizes
    if (image_file_name?)
      self.sizes = {}
      self.image.queued_for_write.each {|key,file|
        next unless File.exists?(file)
        self.sizes[key.to_sym]={}
        geo = Paperclip::Geometry.from_file(file)
        %w(width height).each{|dim|
          self.sizes[key.to_sym][dim.to_sym] = geo.send(dim.to_sym).to_i
        }
      }
    end
  end

  private

  def do_download_remote_image
    io = open(URI.parse(url))
    def io.original_filename; base_uri.path.split('/').last; end
    io.original_filename.blank? ? nil : io
  rescue Exception
    errors.add(:url, "not valid. Unable to download image.")
    return nil
  end

end