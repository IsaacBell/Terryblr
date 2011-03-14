# Be sure to restart your server when you modify this file.

Dummy::Application.config.session_store :active_record_store,
 :key => Settings.session_key,
 :cookie_only => false,
 :secret => 'b2b9dc917f44439635be5b7d07af4b501f14a8f267b2461549fce7229e26fe29f62c3fd42e521d5c570dc524e32d2068a24e1f3490760fb34c09874e41d49fcc'