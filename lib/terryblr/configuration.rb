class Terryblr::Configuration
  attr_accessor :user_model
  attr_accessor :admin_route_prefix
  attr_accessor :admin_route_redirect

  # Configuration defaults
  def initialize
    @user_model           = 'User'
    @admin_route_prefix   = 'admin'
    @admin_route_redirect = "/#{@admin_route_prefix}/pages"

    @overrides = Hash.new { |hash, key| hash[key] = [] }
  end


  def override *args
    overrides = args.extract_options!
    args.each { |arg| overrides[arg] = arg.to_sym }
    overrides.each do | terryblr_classname, host_concern_name |
      unless terryblr_classname.to_s.starts_with? 'Terryblr::'
        terryblr_classname = "Terryblr::#{terryblr_classname}"
      end
      @overrides[terryblr_classname.to_sym] << host_concern_name
    end
  end

  def inject_overrides terryblr_class
    modules = @overrides[terryblr_class.to_s.to_sym]
    modules.each do |hostapp_module_name|
      host_module = hostapp_module_name.to_s.constantize

      terryblr_class.class_eval do
        include host_module
      end
    end
  end

end
