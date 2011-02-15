class Terryblr::Configuration
  attr_accessor :user_model
  attr_accessor :admin_route_prefix
  attr_accessor :admin_route_redirect

  # Configuration defaults
  def initialize
    @user_model           = 'User'
    @admin_route_prefix   = 'admin'
    @admin_route_redirect = "/#{@admin_route_prefix}/pages"
  end

end