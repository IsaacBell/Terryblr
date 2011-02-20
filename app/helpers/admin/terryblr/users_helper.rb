module Admin::Terryblr::UsersHelper
  
  def name_field(user)
    link_to user.full_name, admin_user_path(user)
  end
  
end
