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
    @window = new App.View.Window
    Backbone.history.start pushState: true

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
    $('#content').html("<img src='/images/ajax-loader.gif'>")

    $.get url, (data) =>
      $el = $('<div>').html(data)
      html = $el.find('#content').html()
      $('#content').html html

      title = $el.find('title').text()
      $('title').html title
      @makeArticles()
      $('#content').show()

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

class App.View.Window extends Backbone.View
  el: 'body'
  
  events:
    mousemove: 'mousemove'
    keydown: 'keydown'

  constructor: ->
    super
    @nth = -1
    @sidebar = new App.View.Sidebar parent: @

  keydown: ({keyCode}) =>
    key = String.fromCharCode(keyCode).toLowerCase()
    # move
    switch key
      when 'n' then @nextEntry()
      when 'p' then @prevEntry()
      when 'o' then @openEntry()
      when 'r' then @returnHome()
      when 'g' then $('body').animate {scrollTop: 0}
      when 'j' then @nextHeader()
      when 'k' then @prevHeader()

  collectHeader: ->
    @$("h1,h2,h3,h4,h5")

  createTitleIndex: ->
    $("#sidebar").html do =>
      $list = $('<ul/>').append
      @collectHeader().each (index, el) =>
        $li = $("<li/>")
        $li.text $(el).text()
        $list.append $li

  nextHeader: ->
    last_top = 0
    done = false
    $("h1, h2").each (index, el) ->
      return if done
      $el = $(el)
      top = $el.offset().top

      if last_top <= document.body.scrollTop < top
        $('body').animate {scrollTop: top}
        done = true
      last_top = top

  prevHeader: ->
    done = false
    $("h1, h2").each (index, el) ->
      return if done
      $el = $(el)

      top = $el.offset().top
      if last_top < document.body.scrollTop <= top
        $('body').animate {scrollTop: last_top}
        done = true
      last_top = top

  nextEntry: ->
    page_count = $("h1.title").size()
    last_nth = @nth
    @nth =
      if @nth + 1 < page_count
        @nth + 1
      else
        0
    if last_nth isnt @nth
      @scroll(@nth)

  prevEntry: =>
    page_count = $("h1.title").size()
    last_nth = @nth
    @nth =
      if @nth - 1 > -1
        @nth - 1
      else
        0
    if last_nth isnt @nth
      @scroll(@nth)

  openEntry: =>
    $title = @getTitle(@nth)
    href = $title.find('a').attr('href')
    app.navigate href.substr(1), trigger: true
    @nth = -1

  returnHome: ->
    app.navigate '', trigger: true

  mousemove: ({pageX}) =>
    if @sidebar.isVisible(pageX)
      @sidebar.open()
    else
      @sidebar.close()

  getTitle: (nth)->
    $("h1.title:nth(#{nth})")

  scroll: (nth) =>
    height = $("h1.title:nth(#{nth})").offset().top
    $("body").animate scrollTop: height

class App.View.Sidebar extends Backbone.View
  el: '#sidebar'
  constructor: ->
    super

    {left, top} = $("#content").offset()
    h = window.innerHeight - top
    w = 170

    @$el.css
      left: left
      top: top
      width:  "#{w}px"
      height: "#{h}px"
    @_visible_range_x = w + left

  isVisible: (x) => x < @_visible_range_x 

  open: ->
    @$el.fadeIn()

  close: ->
    @$el.fadeOut()

$ =>
  @app = new App.Workspace()
