class Terryblr::Configuration
  attr_accessor :user_model
  attr_accessor :admin_route_prefix
  attr_accessor :admin_route_redirect

  @@overrides ||= {}
  @@overriden_from ||= {}

  # Configuration defaults
  def initialize
    @user_model           = 'User'
    @admin_route_prefix   = 'admin'
    @admin_route_redirect = "/#{@admin_route_prefix}/pages"
  end

  def overrides
    @@overrides
  end

  def override *args
    from = caller[0]
    overrides = args.extract_options!
    args.each { |arg| overrides[arg] = arg.to_sym }
    overrides.each do | terryblr_classname, host_concern_name |
      unless terryblr_classname.to_s.starts_with? 'Terryblr::'
        terryblr_classname = "Terryblr::#{terryblr_classname}"
      end
      @@overrides[terryblr_classname.to_sym] = [] if @@overrides[terryblr_classname.to_sym].nil?
      @@overrides[terryblr_classname.to_sym] << host_concern_name
      @@overriden_from[terryblr_classname.to_sym] = from
    end
  end

  def inject_overrides terryblr_class
    # Rails.logger.debug { "Injecting overrides in class #{terryblr_class.inspect} !" }
    
    modules = @@overrides[terryblr_class.to_s.to_sym] || []
    
    modules.uniq.each do |hostapp_module_name|
      begin
        host_module = hostapp_module_name.to_s.constantize
        # puts "\t\tInjecting #{host_module} into #{terryblr_class}"
        terryblr_class.instance_eval {
          include host_module
        }
      rescue NameError => e
        from = @overriden_from[terryblr_class.to_s.to_sym] rescue "---"
        puts <<-ERR
        Terryblr configuration error !
        Following Terryblr's configuration, here: #{from.inspect}
        
        Terryblr's' '#{terryblr_class.to_s}' class should be overriden by a class named #{hostapp_module_name.inspect}.
        
        This #{hostapp_module_name.inspect} class could not be loaded !

        ERR
        raise e
      end
    end
  end
end