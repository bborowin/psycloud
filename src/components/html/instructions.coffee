html = require("./html")
Q = require("q")
Markdown = require("./markdown").Markdown
_ = require('lodash')

class Instructions extends html.HtmlStimulus
  constructor: (spec = {}) ->
    super(spec)

    ###
    @pages =

      if @spec.url
      if _.isArray(@spec.url)
        for u in @spec.url
          md = new Markdown({url: u})
      else
        md = new Markdown(@spec.url)
    ###

    @pages = for key, value of @spec.pages
      type = _.keys(value)[0]
      ## assumes type is Markdown
      content = _.values(value)[0]
      md = new Markdown(content)
      div = @div()
      div.addClass("ui stacked segment").append(md.element())
      div.css("overflow-y",  "scroll")
      div.css("height", 800)
      div

    @menu = @div()
    @menu.addClass("ui borderless pagination menu")


    @back = $("""
              <a class="item">
                <i class="icon left arrow"></i>  Previous
               </a>""").attr("id", "instructions_back")

    @next = $("""
              <a class="item">
              Next <i class="icon right arrow"></i>
              </a>""").attr("id", "instructions_next")

    @menu.append(@back).append("\n")

    @items = for i in [1..@pages.length]
      itm = $("""<a class="item">#{i} of #{@pages.length}</a>""")
      @menu.append(itm).append("\n")
      itm

    @items[0].addClass("active")

    @menu.append(@next).css("position", "absolute").css("right", "15px")

    @currentPage = 0

    @el.append(@pages[@currentPage])
    @el.append(@menu)



  activate: (context) ->
    @deferred = Q.defer()
    @deferred.promise

  #start: (context) -> @activate(context)

  updateEl: (currentPage) ->
    @el.empty()
    @el.append(@pages[@currentPage])
    @el.append(@menu)


  render: (context) ->

    @next.click (e) =>
      if (@currentPage < (@pages.length - 1))
        @items[@currentPage].removeClass("active")
        @currentPage += 1
        @items[@currentPage].addClass("active")
        @updateEl(@currentPage)
        @render(context)
        this.emit("next_page")
      else
        this.emit("done")

    @back.click (e) =>
      if (@currentPage > 0)
        @items[@currentPage].removeClass("active")
        @currentPage -= 1
        @items[@currentPage].addClass("active")
        @updateEl(@currentPage)
        @render(context)
        this.emit("previous_page")

    @back.removeClass("disabled") if @currentPage > 0

    $(@pages[@currentPage]).css(
      "min-height": context.height() - 50
    )

    context.appendHtml(@el)
    @presentable(@el)


exports.Instructions = Instructions

