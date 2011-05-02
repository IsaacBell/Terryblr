window.console ||= log: -> null # prevent errors due to console being undefined in some browsers 
puts = _.bind(console.log, console)

App =
  Model: {}
  Views: {}
  Collection: {}
  Controller: {}
  init: (collection) ->
    puts "App initialized."
    new App.Controller.Posts
    Backbone.history.start()

# Models
class App.Model.Post extends Backbone.Model

# Collection
class App.Collection.Posts extends Backbone.Collection

# Views
class App.Views.Index extends Backbone.View
class App.Views.New extends Backbone.View
class App.Views.Edit extends Backbone.View
class App.Views.Delete extends Backbone.View

# Controller
class App.Controller.Posts extends Backbone.Controller