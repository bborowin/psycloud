
Kinetic = Psy.Kinetic

_ = Psy._

@stage = new Kinetic.Stage({
  container: 'container',
  width: $("#container").width(),
  height: 800
})

@Canvas = Psy.Canvas

@context = new Psy.KineticContext(stage)

@ClearEvent = new Psy.Event(new Canvas.Clear(), new Psy.Timeout({duration: 50} ))

@Timeout1000 = new Psy.Timeout({duration: 1000} )

@SpaceKey =  new Psy.SpaceKey()

@AnyKey =  new Psy.AnyKey()

@SpaceOrTimeout5000 = new Psy.First([ new Psy.Timeout({duration: 5000} ),SpaceKey])

@gridlayout = new Psy.GridLayout(8,8, {x:0, y:0, width:@stage.getWidth(), height:@stage.getHeight()})

@makeTrial = (stim, resp, bg=new Canvas.Background([],  "white")) ->
  console.log("making", stim)
  =>
    console.log("starting trial!")
    stim.reset()
    resp.reset()
    new Psy.Trial([new Psy.Event(stim, resp), ClearEvent], {}, null, bg)


@makeResponseTrial = (resp, bg=new Canvas.Background([],  "white")) ->
  =>
    resp.reset()
    new Psy.Trial([new Psy.Event(resp, resp), ClearEvent], {}, bg)

@wrapEvents = (events, bg=new Canvas.Background([], "white")) ->
  => new Psy.Trial(events.concat(ClearEvent), {}, null, bg)



@testSet =
  Basic:
    FixationCross:
      Default: makeTrial(new Canvas.FixationCross(),AnyKey)
      "Blue Fixation": makeTrial(new Canvas.FixationCross({fill: "blue"}),AnyKey)
      "Fixation 200px": makeTrial(new Canvas.FixationCross({length: 200}),AnyKey)
      "Fixation 50%": makeTrial(new Canvas.FixationCross({length: '50%'}),AnyKey)

      "Fixation stroke width 20px": makeTrial(new Canvas.FixationCross({strokeWidth: 20}),AnyKey)
    Text:
      "Positioning with Labels": makeTrial(new Psy.Group(
        [new Canvas.Text({content: "Center", origin: "center", position: "center", fontSize: 20}),
         new Canvas.Text({content: "Center Left", origin: "center", position: "center-left", fontSize: 20}),
         new Canvas.Text({content: "Center Right", origin: "center", position: "center-right", fontSize: 20}),
         new Canvas.Text({content: "Top Left", origin: "center", position: "top-left", fontSize: 20}),
         new Canvas.Text({content: "Top Right", origin: "center", position: "top-right", fontSize: 20}),
         new Canvas.Text({content: "Top Center", origin: "center", position: "top-center", fontSize: 20}),
         new Canvas.Text({content: "Bottom Left", origin: "center", position: "bottom-left", fontSize: 20}),
         new Canvas.Text({content: "Bottom Right", origin: "center", position: "bottom-right", fontSize: 20}),
         new Canvas.Text({content: "Bottom Center", origin: "center", position: "bottom-center", fontSize: 20})
        ]), SpaceKey)

      "75 Point Font": makeTrial(new Canvas.Text({content: "75 Point Font", position: "center", origin: "center", fontSize: 75}),SpaceKey)
      "12 Point Font": makeTrial(new Canvas.Text({content: "12 Point Font", position: "center", origin: "center", fontSize: 12}),SpaceKey)
      "Paragraph": makeTrial(new Canvas.Text({
        content:
          "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\n
          Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor\n
          in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident,\n
          sunt in culpa qui officia deserunt mollit anim id est laborum."
        width:800,
        fontSize: 24}),
        SpaceKey)
      "Origin Test": makeTrial(new Psy.Group(
        for org in ["top-left", "top-right", "top-center", "center-left", "center-right", "center", "bottom-left", "bottom-right", "bottom-center"]
          new Canvas.Text({content: "+", position: ["50%", "50%"], fontSize: 18, origin: org, fill: "red" })
        ), SpaceKey)

      "Multiple Lines, origin top-left": makeTrial(new Canvas.Text({
          content: ["End of Block", "Average RT: 772", "Press Space Bar to continue to next block"]
          position: "center"
          origin: "center"
        }), SpaceKey)

    Background:
      "Background fill": wrapEvents([
        new Psy.Event(new Canvas.Text({content: "Hello,"}), Timeout1000),
        new Psy.Event(new Canvas.Text({content: "How"}), Timeout1000),
        new Psy.Event(new Canvas.Text({content: "are"}), Timeout1000),
        new Psy.Event(new Canvas.Text({content: "you"}), Timeout1000),
        new Psy.Event(new Canvas.Text({content: "Today"}), SpaceKey)],
        new Canvas.Background([new Canvas.Text({content: "I am a background stimulus", position: "bottom-center"})],  "red"))


    Blank:
      "Black Background": makeTrial(new Canvas.Blank({fill: "black"}), SpaceKey)
      "Green Background": makeTrial(new Canvas.Blank({fill: "green"}), SpaceKey)
      "RGB (33, 55, 67)": makeTrial(new Canvas.Blank({fill: "rgb(33,55,67)"}), SpaceKey)

    CanvasBorder:
      "Default": makeTrial(new Canvas.CanvasBorder(), SpaceKey)
      "Blue Border": makeTrial(new Canvas.CanvasBorder({stroke: "blue"}), SpaceKey)
      "Thick Blue Border": makeTrial(new Canvas.CanvasBorder({stroke: "blue", strokeWidth: 20}), SpaceKey)

    GridLines:
      "Default GridLines": makeTrial(new Canvas.GridLines(), SpaceKey)
      "5 X 5 GridLines": makeTrial(new Canvas.GridLines({rows:5, cols:5}), SpaceKey)
      "5 X 5 Dashed GridLines": makeTrial(new Canvas.GridLines({rows:5, cols:5, dashArray: [10,5]}), SpaceKey)
      "5 X 5 Dashed GridLines smaller grid": makeTrial(new Canvas.GridLines({rows:5, cols:5, x:200, y:200, width: 300, height:300, dashArray: [10,5]}), SpaceKey)


    Rectangle:
      "Default Rect": makeTrial(new Canvas.Rectangle(x:5, y:5), SpaceKey)
      "Unfilled Rect": makeTrial(new Canvas.Rectangle(x:5, y:5, fill: false, stroke: "black"), SpaceKey)
      "Green Square 500 by 500": makeTrial(new Canvas.Rectangle({width: 500, height: 500, fill: "green"}), SpaceKey)
      "Green Square Blue Stroke": makeTrial(new Canvas.Rectangle({width: 500, height: 500, fill: "green", stroke: "blue"}), SpaceKey)
      "Default Rect, x 50%, y 50%": makeTrial(new Canvas.Rectangle({position: ["50%","50%"]}), SpaceKey)
      "Default Rect, grid 3,3 [0,0]": makeTrial(new Canvas.Rectangle({position: [0,0], layout: new Psy.GridLayout(3,3, {x:0, y:0, width:800, height:800})}), SpaceKey)
      "Default Rect, grid 3,3 [2,2]": makeTrial(new Canvas.Rectangle({position: [2,2], layout: new Psy.GridLayout(3,3, {x:0, y:0, width:stage.getWidth(), height:stage.getHeight()})}), SpaceKey)
      "Default Rect, grid 3,3 offset 200, 200 [0,0]": makeTrial(new Canvas.Rectangle({position: [0,0], origin: "center", layout: new Psy.GridLayout(3,3, {x:100, y:100, width:stage.getWidth()-200, height:stage.getHeight()-200})}), SpaceKey)
      "Rect Grid": makeTrial(new Psy.Grid(
          _.flatten(for row in [0...3]
            for col in [0...3]
              new Canvas.Rectangle({position: [row,col], width: 50, height: 50, origin: "center"}))
          , 3, 3, { x: 200, y: 200, width: 300, height: 300 }), SpaceKey)

    LabeledElement:
      "Labeled Rect": makeTrial(new Canvas.LabeledElement(new Canvas.Rectangle(x:5, y:5), { align: "center"}), SpaceKey)
      "Labeled Arrow": makeTrial(new Canvas.LabeledElement(new Canvas.Arrow(angle: 45), { fontSize: 24, align: "left" }), SpaceKey)
      "Labeled Rect above": makeTrial(new Canvas.LabeledElement(new Canvas.Rectangle(x: 400, y: 400), {position:"above"}), SpaceKey)
      "Labeled Circle above": makeTrial(new Canvas.LabeledElement(new Canvas.Circle(x: 400, y: 400, radius: 50), {position:"above"}), SpaceKey)
      "Labeled Circle below": makeTrial(new Canvas.LabeledElement(new Canvas.Circle(x: 400, y: 400, radius: 50), {position:"below"}), SpaceKey)
      "Labeled Circle right": makeTrial(new Canvas.LabeledElement(new Canvas.Circle(x: 400, y: 400, radius: 50), {position:"right"}), SpaceKey)
      "Labeled Circle left": makeTrial(new Canvas.LabeledElement(new Canvas.Circle(x: 400, y: 400, radius: 50), {position:"left"}), SpaceKey)


    Circle:
      "Default Circle": makeTrial(new Canvas.Circle(), SpaceKey)
      "Green Circle Radius 50": makeTrial(new Canvas.Circle({radius: 50, fill: "green"}), SpaceKey)
      "Green Circle Blue Stroke": makeTrial(new Canvas.Circle({radius: 50, fill: "green", stroke: "blue"}), SpaceKey)
      #"Centered 100px circle": makeTrial(new Canvas.Circle({radius: 100, fill: "green", stroke: "blue", position: "center", origin: "center"}), SpaceKey)
      "Centered 100px circle": makeTrial(new Canvas.Circle({position: "center", radius: 100, origin: "center", fill: "green"}), SpaceKey)
      "Position Test": makeTrial(new Psy.Group(
        for org in ["top-left", "top-right", "top-center", "center-left", "center-right", "center", "bottom-left", "bottom-right", "bottom-center"]
          new Canvas.Circle({position: org, radius: 50, origin: "center", fill: '#'+(Math.random()*0xFFFFFF<<0).toString(16)})
      ), SpaceKey)
      "Row of Circles": makeTrial(new Psy.Grid(
        for col in [0...3]
          new Canvas.Circle({position: [0,col], radius: 25, origin: "center"})
        , 1, 3, { x: 200, y: 200, width: 300, height: 300 }), SpaceKey)
      "Column of Circles": makeTrial(new Psy.Grid(
        for row in [0...3]
          new Canvas.Circle({position: [row,0], radius: 25, origin: "center"})
        , 3, 1, { x: 200, y: 200, width: 300, height: 300 }), SpaceKey)


    Arrow:
      "Default Arrow": makeTrial(new Canvas.Arrow(), SpaceKey)
      "Blue Arrow, length 200": makeTrial(new Canvas.Arrow({length: 200, fill: "blue"}), SpaceKey)
      "Blue Arrow, black stroke": makeTrial(new Canvas.Arrow({length: 200, fill: "blue", stroke: "black", strokeWidth: 4}), SpaceKey)
      "Arrow Origin Test": makeTrial(new Psy.Group(
        _.flatten(for org, index in ["top-left", "center", "bottom-right"]
          clrs = ["red", "blue", "green"]
          [new Canvas.Arrow({x:200, y:200, origin: org, length: 200, origin: org, fill: clrs[index]}), new Canvas.Circle({x: 200 * index, y:200 * index, fill: "black", radius: 5})])
      ), SpaceKey)


      "Rotating Arrow": makeTrial(new Psy.Sequence(
        for i in [0 .. 360] by 2
          new Canvas.Arrow({x:300, y:300, length: 200, fill: "black", angle: i})
        [40]), SpaceKey)

      "Rotating Arrow no clear": makeTrial(new Psy.Sequence(
        for i in [0 .. 360] by 2
          new Canvas.Arrow({x:300, y:300, length: 200, fill: "black", angle: i, opacity: i/720})
        [40], clear=false),SpaceKey)
      "Position Test": makeTrial(new Psy.Group(
        for org in ["top-left", "top-right", "top-center", "center-left", "center-right", "center", "bottom-left", "bottom-right", "bottom-center"]
          new Canvas.Arrow({position: org, length: 50, origin: "center", fill: '#'+(Math.random()*0xFFFFFF<<0).toString(16)})
      ), SpaceKey)

  Media:
    Picture:
      "Default Picture": makeTrial(new Canvas.Picture(), SpaceKey)
      "Default 300 X 300": makeTrial(new Canvas.Picture({width: 300, height: 300}), SpaceKey)
      "Flicker Two Images 4Hz": makeTrial(new Psy.Sequence(
        [ new Canvas.Picture(url: "images/Sunset.jpg"),
          new Canvas.Picture(url: "images/Shark.jpg")],
        [250,250], clear=true, times=50), SpaceKey)
    Sound:
      Default: makeTrial(new Psy.Sound(), SpaceKey)


  HTML:
    HtmlIcon:
      Default: makeTrial(new Psy.Html.HtmlIcon(), SpaceKey)
      PercentagePositioning: makeTrial(new Psy.Html.HtmlIcon({label: "[50%,50%]", x: "40%", y: "40%"}), SpaceKey)

    HtmlLabel:
      Default: makeTrial(new Psy.Html.HtmlLabel(glyph: "fighter jet"), SpaceKey)
      "Centered Red Label": makeTrial(new Psy.Html.HtmlLabel(text: "centered red label", position: "center", origin: "center", color: "red"), SpaceKey)
      "Centered Green Label with glyph": makeTrial(new Psy.Html.HtmlLabel(text: "centered green label", position: "center", glyph: "fighter jet", color:" green", origin: "center"), SpaceKey)

    HtmlLink:
      Default: makeTrial(new Psy.Html.HtmlLink(), SpaceKey)
      XYPositioning: makeTrial(new Psy.Html.HtmlLink({label: "[100,100]", x: 100, y: 100}), SpaceKey)
      PercentagePositioning: makeTrial(new Psy.Html.HtmlLink({label: "[80%,80%]", x: "80%", y: "80%"}), SpaceKey)

    HtmlButton:
      Default: makeTrial(new Psy.Html.HtmlButton(), SpaceOrTimeout5000)
      PercentagePositioning: makeTrial(new Psy.Html.HtmlButton({label: "[80%,80%]", x: "80%", y: "80%"}), SpaceKey)
      CircularButton: makeTrial(new Psy.Html.HtmlButton({label: "[50%,50%]", x: "50%", y: "50%", class: "circular"}), SpaceKey)
      "Button over Crosshair": makeTrial(new Psy.Group([
        new Psy.Html.HtmlButton({label: "[50%,50%]", x: "50%", y: "50%", class: "circular huge"}),
        new Canvas.FixationCross()
      ]), SpaceKey)

    #HtmlRange:
    #  Default: makeTrial(new Psy.Html.HtmlRange(), SpaceKey)

    Markdown:
      "Basic Example": makeTrial(new Psy.Html.Markdown("""

      A First Level Header Today tttt
      ===================
      A Second Level Header Tday tttt
      ---------------------
      ### Header 3


      Now is the time for all good men to come to
      the aid of their country. This is just a
      regular paragraph.

      The quick brown fox jumped over the lazy
      dog's back.

      > This is a blockquote.
      >
      > This is the second paragraph in the blockquote.
      >
      > ## This is an H2 in a blockquote

      ![alt text](http://www.html5canvastutorials.com/demos/assets/yoda.jpg "Title")


    """), SpaceKey)

      #"An External URL": makeTrial(new Psy.Html.Markdown({url: "./resources/page-1.md"}), SpaceKey)


    Page:
      "Test Html": makeTrial(new Psy.Html.Page(), SpaceKey)

      Message: makeTrial(new Psy.Html.Page(
        html:
          """
        <div class="ui message">
          <div class="header">
            Welcome back!
          </div>
          <p>
            It's good to see you again. I have had a lot to think about since our last visit, I've changed much as a person and I can see that you have too.
          </p>
          <p>
            Perhaps we can talk about it if you have the time.
          </p>
        </div>
        <div class="ui icon message">
          <i class="inbox icon"></i>
          <div class="content">
          <div class="header">
            Have you heard about our mailing list?
          </div>
          <p>Get all the best inventions in your e-mail every day. Sign up now!</p>
          </div>
        </div>
        """
        ), SpaceKey)

    Message:
      "Default": makeTrial(new Psy.Html.Message(), SpaceKey)
      "Basic Message in Red": makeTrial(new Psy.Html.Message({
        title: "This is a massive message in red"
        content: """
          Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
          Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure
          dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non
          proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
        """
        color: "red"
        size: "massive"
      }), SpaceKey)
      "Multiple Messages": makeTrial(new Psy.Group(
        [new Psy.Html.Message({ title: "message 1", content: "This is Message 1", color: "blue"}),
        new Psy.Html.Message({ title: "message 2", content: "This is Message 2", color: "red"}),
        new Psy.Html.Message({ title: "message 3", content: "This is Message 3", color: "green"})
        ]), SpaceKey)

      "Message and Canvas Rect": makeTrial(new Psy.Group(
        [new Psy.Html.Message({ title: "message 1", content: "This is Message 1", color: "blue"}),
        new Canvas.FixationCross()]), SpaceKey)
  Dialogs:
    Prompt:
      Default:
        makeTrial(Timeout1000, new Psy.Prompt({ title: "How old are you?"}))
    Confirm:
      Default:
        makeTrial(Timeout1000, new Psy.Confirm({ message: "Do you want to continue?"}))

  Collection:
    Sequence:
      "Count to Three": makeTrial(new Psy.Sequence(
        [ new Canvas.Text({content: "One", position: "center"}),
          new Canvas.Text({content: "Two", position: "center"}),
          new Canvas.Text({content: "Three", position: "center"})],
        [1000, 2000, 4000]), SpaceKey)
      "Count to Three with Overlay": makeTrial(new Psy.Sequence(
        [ new Canvas.Text({content: "One", position: "center-left"}),
          new Canvas.Text({content: "Two", position: "center"}),
          new Canvas.Text({content: "Three", position: "center-right"})],
        [1000, 2000, 4000], clear=false), SpaceKey)
      "Fast Countdown": makeTrial(new Psy.Sequence(
        for i in [50..0]
          r = i*4
          g = 255 - (i*4)
          b = i
          new Canvas.Text({content: i, position: "center", fontSize: 80 + i*2, fill: "rgb(#{r},#{g},#{b})"})
        [80]), SpaceKey)
      "Repeating Squares": makeTrial(new Psy.Sequence(
        [ new Canvas.Rectangle({position: [2,2], width: 80, height: 80, fill: "red", layout: gridlayout}),
          new Canvas.Rectangle({position: [2,3], width: 80, height: 80, fill: "blue", layout: gridlayout}),
          new Canvas.Rectangle({position: [2,4], width: 80, height: 80, fill: "yellow", layout: gridlayout})
        ], [100], true, 9), SpaceKey)

  Tasks:
    "Arrow Flanker": -> "../arrow_flanker_index.html"


  Response: null



@activeTrial = null
@autostart = true


@startTrial = ($el, subels, trial) ->
  context.clearContent()
  trial.start(context, ->
    console.log("calling back")
    if @autostart
      $elnext = $el.next()
      console.log("next el", $elnext)
      console.log("next el text is", $elnext.text().trim())
      console.log("next el text length", $elnext.text().trim().length)
      console.log("first sibling text is", $el.siblings().first().text().trim())
      if $elnext.text().trim().length is 0
        selectTest($el.siblings().first(), subels)
      else
        selectTest($elnext, subels)


  )

@selectTest = ($el, subels) ->
  key = $el.text().trim()
  $el.addClass("active")
  $el.siblings().removeClass("active")
  trial = subels[key]
  if @activeTrial
    @activeTrial.stop()
  @activeTrial = trial()
  if @autostart
    startTrial($el, subels, @activeTrial)




window.updateTests = (category, name) ->
  subels = testSet[category][name]
  testlist = $("#testmenu")
  testlist.children().remove()

  for key, value of subels
    testlist.append("""<a href='#' class="item" id=#{key}> #{key}</a>""")

  $("#testmenu > a").click (e) ->
    $this = $(this)
    selectTest($this, subels)

    context.clearContent()
    $("#start").click (e) =>
      context.clearContent()
      if @activeTrial?
        @activeTrial.start(context, ->
          console.log("calling back")
          if @autostart
            selectTest($this.next(), subels)

        )



$(document).ready =>
  #$('.ui.checkbox').checkbox()
  @autostart = $("#checkid").is(":checked")



  categories = $("#compmenu")
  for key, value of testSet
    $el = $("""<div class="header item category" id=#{key}> #{key} </div>""")
    categories.append($el)
    for skey, svalue of value
      item = $("""<a href='#' class="item" id=#{skey}> #{skey}</a>""")
      item.addClass("compitem")
      #$el.append(item)
      categories.append(item)

  $("#checkid").on("click", (e) ->
    console.log("enable")
    console.log($(this))
    console.log(this.checked)
  )


  $("#compmenu >  a" ).click (e) ->
    console.log("clicked menu item")
    menu = $("#compmenu > a")
    console.log("cur", menu)
    console.log("children", menu.children())
    console.log("this", $(this))
    console.log("compitem", $(".compitem"))
    $(this).addClass("active")
    $(this).siblings().removeClass("active")
    console.log("number of siblings", $(this).siblings(".header.item").length)
    console.log("prevAll", $(this).prevAll(".category").first().text())
    category = $(this).prevAll(".category").first().text().trim()
    #cur.removeClass("active")
    #cur.children("li").hide()

    #$(this).addClass("active")
    #category = $(this).parent().clone().children().remove().end().text().trim()
    name = $(this).text().trim()
    name = name.replace(/\s+/g, "")
    console.log("name", name)
    console.log("category", category)
    updateTests(category, name)





