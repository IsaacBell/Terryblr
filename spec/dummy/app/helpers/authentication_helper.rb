module AuthenticationHelper
  username = "admin"
  password = "admin"
  

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      true
      #username == self.username && password == self.password
    end
  end
  
  def current_user
    {}
  end
end
