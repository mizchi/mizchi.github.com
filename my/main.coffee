@App =
  View: {}
@app = null

class App.Workspace extends Backbone.Router
  routes:
    '': 'index'
    'blog/:year/:month/:day/:title/': 'entry'
    'blog/archives': 'archives'
    'blog/categories/:tag/': 'category'

  constructor: ->
    super
    @header = new App.View.Header
    @initialized = false

  index: =>
    unless @initialized
      @updateContent location.pathname
    else
      @makeArticles()
      @initialized = true

  category: (tag) =>
    unless @initialized
      @updateContent location.pathname
    else
      @makeArticles()
      @initialized = true

  entry: (year, month, day, title) =>
    unless @initialized
      url = "/blog/#{year}/#{month}/#{day}/#{title}/"
      @updateContent url
    else
      @makeArticles()
      @initialized = true

  archives: =>
    unless @initialized
      @updateContent '/blog/archives'
    else
      @makeArticles()
      @initialized = true

  makeArticles: ->
    @articles = $('article.post').map (index, el) =>
      new App.View.Article el: el

  updateContent: (url) ->
    $.get url, (data) =>
      $el = $('<div>').html(data)
      html = $el.find('#content').html()
      $('#content').html html

      title = $el.find('title').text()
      $('title').html title
      @makeArticles()

class App.View.Header extends Backbone.View
  el: '#header'
  events:
    'click h1 > a': 'index'
    "click a[href='/']": 'index'
    "click a[href='/blog/archives']": 'toArchives'

  toArchives: (event) =>
    event.preventDefault()
    app.navigate 'blog/archives', trigger: true

  index: (event) =>
    event.preventDefault()
    app.navigate '', trigger: true

class App.View.Article extends Backbone.View
  events:
    'click h1.title a': 'toEntry'
    "click a.category": 'toCategory'

  toEntry: (event, el) =>
    event.preventDefault()
    href = @$el.find('h1.title > a').attr('href')
    app.navigate href.substr(1), trigger: true

  toCategory: (event, el) =>
    console.log arguments...
    event.preventDefault()
    href = @$(event.target).attr('href')
    app.navigate href.substr(1), trigger: true

$ =>
  @app = new App.Workspace()
  Backbone.history.start pushState: true