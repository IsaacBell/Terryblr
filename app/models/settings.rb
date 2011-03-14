class Settings < Settingslogic
  source "#{Rails.root}/config/settings.yml"
  namespace Rails.env

  def s3_enabled?
    !!(s3.access_key_id.present? && s3.secret_access_key.present? if respond_to? :s3)
  end
end