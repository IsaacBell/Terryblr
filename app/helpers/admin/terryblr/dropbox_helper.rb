module Admin::Terryblr::DropboxHelper

  def dropbox_session
    puts "Un-memoized #dropbox_session"
    @dropbox_session ||= begin
      puts "MEMOIZED #dropbox_session"
      previous = Dropbox::Session.deserialize(session[:dropbox_session]) if session[:dropbox_session]
      if previous && previous.authorized?
        previous
      elsif previous && params[:oauth_token]
        puts "Trying to authorize an existing dropbox session..."
        unless previous.authorized?
          previous.authorize(params)
          session[:dropbox_session] = previous.serialize # re-serialize the authenticated session
          previous
        end
      else
        puts "Creating a new Dropbox session..."
        new_dropbox_session.tap do |dropbox_session|
          session[:dropbox_session] = dropbox_session.serialize
        end
      end
    end
  end

  def new_dropbox_session
    Dropbox::Session.new(Terryblr::Settings.dropbox_app.key, Terryblr::Settings.dropbox_app.secret)
  end

  def dropbox_authorize_link
    dropbox_session.authorize_url(:oauth_callback => request.url)
  end

  def basename(path)
    path.sub(@dropbox_path, '').sub(/^\//, '')
  end
  include Terryblr::Extendable
end
