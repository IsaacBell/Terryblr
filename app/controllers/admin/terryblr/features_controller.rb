class Admin::Terryblr::FeaturesController < Terryblr::AdminController

  helper 'admin/terryblr/features'

  def index
    @show_as_dash = true
    @collections = {}
    Settings.tags.posts.features.map do |tag|
      @collections[tag] = end_of_association_chain.live.tagged_with(tag)
    end
  end

  def new
    # Create feature!
    object.attributes = object.class.new.attributes.symbolize_keys.update(:state => "pending", :published_at => nil)
    object.save!
    super
  end

  def show
    super do |wants|
      wants.html { redirect_to edit_admin_feature_path(object) }
    end
  end

  def update
    super do |wants|
      wants.html { redirect_to admin_features_path }
    end
  end

  def reorder
    key = params.keys.detect{|k| k.to_s.starts_with?('feature') }
    if params[key].is_a?(Array)
      i = 0
      params[key].each do |id|
        end_of_association_chain.update_all({:display_order => (i+=1)}, {:id => id})
      end
      render :nothing => true, :status => :ok
    else
      render :nothing => true, :status => :error
    end
  end

  private

  def end_of_association_chain
    Terryblr::Feature
  end

  def object
    @object ||= end_of_association_chain.find(params[:id])
  end

  include Terryblr::Extendable
end