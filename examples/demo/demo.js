// Generated by CoffeeScript 1.7.1
(function() {
  var b, clear, clrs, col, g, i, index, org, r, row, times, _;

  Psy.Kinetic = Kinetic;

  _ = Psy._;

  this.stage = new Kinetic.Stage({
    container: 'container',
    width: $("#container").width(),
    height: 800
  });

  this.Canvas = Psy.Canvas;

  this.context = new Psy.KineticContext(stage);

  this.ClearEvent = new Psy.Event(new Canvas.Clear(), new Psy.Timeout({
    duration: 50
  }));

  this.Timeout1000 = new Psy.Timeout({
    duration: 1000
  });

  this.SpaceKey = new Psy.SpaceKey();

  this.AnyKey = new Psy.AnyKey();

  this.SpaceOrTimeout5000 = new Psy.First([
    new Psy.Timeout({
      duration: 5000
    }), SpaceKey
  ]);

  this.LikertSelection = new Psy.Receiver({
    id: "likert_selection"
  });

  this.ChangeReceiver = new Psy.Receiver({
    id: "change"
  });

  this.Instructions_Done = new Psy.Receiver({
    id: "done"
  });

  this.gridlayout = new Psy.GridLayout(8, 8, {
    x: 0,
    y: 0,
    width: this.stage.getWidth(),
    height: this.stage.getHeight()
  });

  this.makeTrial = function(stim, resp, bg) {
    if (bg == null) {
      bg = new Canvas.Background([], "white");
    }
    console.log("making", stim);
    return (function(_this) {
      return function() {
        console.log("starting trial! with", stim);
        console.log("resp is", resp);
        stim.reset();
        resp.reset();
        return new Psy.Trial([new Psy.Event(stim, resp), ClearEvent], {}, null, bg);
      };
    })(this);
  };

  this.fromEventSpec = function(spec) {
    return (function(_this) {
      return function() {
        var bg, event, factory;
        factory = new Psy.DefaultComponentFactory();
        event = factory.buildEvent(spec);
        bg = new Canvas.Background([], "white");
        return new Psy.Trial([event], {}, null, bg);
      };
    })(this);
  };

  this.makeResponseTrial = function(resp, bg) {
    if (bg == null) {
      bg = new Canvas.Background([], "white");
    }
    return (function(_this) {
      return function() {
        resp.reset();
        return new Psy.Trial([new Psy.Event(resp, resp), ClearEvent], {}, bg);
      };
    })(this);
  };

  this.wrapEvents = function(events, bg) {
    if (bg == null) {
      bg = new Canvas.Background([], "white");
    }
    return (function(_this) {
      return function() {
        return new Psy.Trial(events.concat(ClearEvent), {}, null, bg);
      };
    })(this);
  };

  this.testSet = {
    Basic: {
      FixationCross: {
        Default: makeTrial(new Canvas.FixationCross(), AnyKey),
        "Blue Fixation": makeTrial(new Canvas.FixationCross({
          fill: "blue"
        }), AnyKey),
        "Fixation 200px": makeTrial(new Canvas.FixationCross({
          length: 200
        }), AnyKey),
        "Fixation 50%": makeTrial(new Canvas.FixationCross({
          length: '50%'
        }), AnyKey),
        "Fixation stroke width 20px": makeTrial(new Canvas.FixationCross({
          strokeWidth: 20
        }), AnyKey)
      },
      Title: {
        Default: makeTrial(new Canvas.Title(), SpaceKey),
        WithOffset100px: makeTrial(new Canvas.Title({
          content: "This is a title",
          yoffset: 100
        }), SpaceKey),
        LeftJustified: makeTrial(new Canvas.Title({
          content: "This is a title",
          align: "left"
        }), SpaceKey)
      },
      Text: {
        "Positioning with Labels": makeTrial(new Psy.Group([
          new Canvas.Text({
            content: "Center",
            origin: "center",
            position: "center",
            fontSize: 20
          }), new Canvas.Text({
            content: "Center Left",
            origin: "center",
            position: "center-left",
            fontSize: 20
          }), new Canvas.Text({
            content: "Center Right",
            origin: "center",
            position: "center-right",
            fontSize: 20
          }), new Canvas.Text({
            content: "Top Left",
            origin: "center",
            position: "top-left",
            fontSize: 20
          }), new Canvas.Text({
            content: "Top Right",
            origin: "center",
            position: "top-right",
            fontSize: 20
          }), new Canvas.Text({
            content: "Top Center",
            origin: "center",
            position: "top-center",
            fontSize: 20
          }), new Canvas.Text({
            content: "Bottom Left",
            origin: "center",
            position: "bottom-left",
            fontSize: 20
          }), new Canvas.Text({
            content: "Bottom Right",
            origin: "center",
            position: "bottom-right",
            fontSize: 20
          }), new Canvas.Text({
            content: "Bottom Center",
            origin: "center",
            position: "bottom-center",
            fontSize: 20
          })
        ]), SpaceKey),
        "75 Point Font": makeTrial(new Canvas.Text({
          content: "75 Point Font",
          position: "center",
          origin: "center",
          fontSize: 75
        }), SpaceKey),
        "12 Point Font": makeTrial(new Canvas.Text({
          content: "12 Point Font",
          position: "center",
          origin: "center",
          fontSize: 12
        }), SpaceKey),
        "Paragraph": makeTrial(new Canvas.Text({
          content: "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\n Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor\n in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident,\n sunt in culpa qui officia deserunt mollit anim id est laborum.",
          width: 800,
          fontSize: 24
        }), SpaceKey),
        "Origin Test": makeTrial(new Psy.Group((function() {
          var _i, _len, _ref, _results;
          _ref = ["top-left", "top-right", "top-center", "center-left", "center-right", "center", "bottom-left", "bottom-right", "bottom-center"];
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            org = _ref[_i];
            _results.push(new Canvas.Text({
              content: "+",
              position: ["50%", "50%"],
              fontSize: 18,
              origin: org,
              fill: "red"
            }));
          }
          return _results;
        })()), SpaceKey),
        "Multiple Lines, origin top-left": makeTrial(new Canvas.Text({
          content: ["End of Block", "Average RT: 772", "Press Space Bar to continue to next block"],
          position: "center",
          origin: "center"
        }), SpaceKey)
      },
      Background: {
        "Background fill": wrapEvents([
          new Psy.Event(new Canvas.Text({
            content: "Hello,"
          }), Timeout1000), new Psy.Event(new Canvas.Text({
            content: "How"
          }), Timeout1000), new Psy.Event(new Canvas.Text({
            content: "are"
          }), Timeout1000), new Psy.Event(new Canvas.Text({
            content: "you"
          }), Timeout1000), new Psy.Event(new Canvas.Text({
            content: "Today"
          }), SpaceKey)
        ], new Canvas.Background([
          new Canvas.Text({
            content: "I am a background stimulus",
            position: "bottom-center"
          })
        ], "red"))
      },
      Blank: {
        "Black Background": makeTrial(new Canvas.Blank({
          fill: "black"
        }), SpaceKey),
        "Green Background": makeTrial(new Canvas.Blank({
          fill: "green"
        }), SpaceKey),
        "RGB (33, 55, 67)": makeTrial(new Canvas.Blank({
          fill: "rgb(33,55,67)"
        }), SpaceKey)
      },
      CanvasBorder: {
        "Default": makeTrial(new Canvas.CanvasBorder(), SpaceKey),
        "Blue Border": makeTrial(new Canvas.CanvasBorder({
          stroke: "blue"
        }), SpaceKey),
        "Thick Blue Border": makeTrial(new Canvas.CanvasBorder({
          stroke: "blue",
          strokeWidth: 20
        }), SpaceKey)
      },
      GridLines: {
        "Default GridLines": makeTrial(new Canvas.GridLines(), SpaceKey),
        "5 X 5 GridLines": makeTrial(new Canvas.GridLines({
          rows: 5,
          cols: 5
        }), SpaceKey),
        "5 X 5 Dashed GridLines": makeTrial(new Canvas.GridLines({
          rows: 5,
          cols: 5,
          dashArray: [10, 5]
        }), SpaceKey),
        "5 X 5 Dashed GridLines smaller grid": makeTrial(new Canvas.GridLines({
          rows: 5,
          cols: 5,
          x: 200,
          y: 200,
          width: 300,
          height: 300,
          dashArray: [10, 5]
        }), SpaceKey)
      },
      Rectangle: {
        "Default Rect": makeTrial(new Canvas.Rectangle({
          x: 5,
          y: 5
        }), SpaceKey),
        "Unfilled Rect": makeTrial(new Canvas.Rectangle({
          x: 5,
          y: 5,
          fill: false,
          stroke: "black"
        }), SpaceKey),
        "Green Square 500 by 500": makeTrial(new Canvas.Rectangle({
          width: 500,
          height: 500,
          fill: "green"
        }), SpaceKey),
        "Green Square Blue Stroke": makeTrial(new Canvas.Rectangle({
          width: 500,
          height: 500,
          fill: "green",
          stroke: "blue"
        }), SpaceKey),
        "Default Rect, x 50%, y 50%": makeTrial(new Canvas.Rectangle({
          position: ["50%", "50%"]
        }), SpaceKey),
        "Default Rect, grid 3,3 [0,0]": makeTrial(new Canvas.Rectangle({
          position: [0, 0],
          layout: new Psy.GridLayout(3, 3, {
            x: 0,
            y: 0,
            width: 800,
            height: 800
          })
        }), SpaceKey),
        "Default Rect, grid 3,3 [2,2]": makeTrial(new Canvas.Rectangle({
          position: [2, 2],
          layout: new Psy.GridLayout(3, 3, {
            x: 0,
            y: 0,
            width: stage.getWidth(),
            height: stage.getHeight()
          })
        }), SpaceKey),
        "Default Rect, grid 3,3 offset 200, 200 [0,0]": makeTrial(new Canvas.Rectangle({
          position: [0, 0],
          origin: "center",
          layout: new Psy.GridLayout(3, 3, {
            x: 100,
            y: 100,
            width: stage.getWidth() - 200,
            height: stage.getHeight() - 200
          })
        }), SpaceKey),
        "Rect Grid": makeTrial(new Psy.Grid(_.flatten((function() {
          var _i, _results;
          _results = [];
          for (row = _i = 0; _i < 3; row = ++_i) {
            _results.push((function() {
              var _j, _results1;
              _results1 = [];
              for (col = _j = 0; _j < 3; col = ++_j) {
                _results1.push(new Canvas.Rectangle({
                  position: [row, col],
                  width: 50,
                  height: 50,
                  origin: "center"
                }));
              }
              return _results1;
            })());
          }
          return _results;
        })()), 3, 3, {
          x: 200,
          y: 200,
          width: 300,
          height: 300
        }), SpaceKey)
      },
      LabeledElement: {
        "Labeled Rect": makeTrial(new Canvas.LabeledElement(new Canvas.Rectangle({
          x: 5,
          y: 5
        }), {
          align: "center"
        }), SpaceKey),
        "Labeled Arrow": makeTrial(new Canvas.LabeledElement(new Canvas.Arrow({
          angle: 45
        }), {
          fontSize: 24,
          align: "left"
        }), SpaceKey),
        "Labeled Rect above": makeTrial(new Canvas.LabeledElement(new Canvas.Rectangle({
          x: 400,
          y: 400
        }), {
          position: "above"
        }), SpaceKey),
        "Labeled Rect over": makeTrial(new Canvas.LabeledElement(new Canvas.Rectangle({
          x: 400,
          y: 400,
          fill: "gray"
        }), {
          position: "over"
        }), SpaceKey),
        "Labeled Circle above": makeTrial(new Canvas.LabeledElement(new Canvas.Circle({
          x: 400,
          y: 400,
          radius: 50
        }), {
          position: "above"
        }), SpaceKey),
        "Labeled Circle below": makeTrial(new Canvas.LabeledElement(new Canvas.Circle({
          x: 400,
          y: 400,
          radius: 50
        }), {
          position: "below"
        }), SpaceKey),
        "Labeled Circle right": makeTrial(new Canvas.LabeledElement(new Canvas.Circle({
          x: 400,
          y: 400,
          radius: 50
        }), {
          position: "right"
        }), SpaceKey),
        "Labeled Circle left": makeTrial(new Canvas.LabeledElement(new Canvas.Circle({
          x: 400,
          y: 400,
          radius: 50
        }), {
          position: "left"
        }), SpaceKey),
        "Labeled Circle over": makeTrial(new Canvas.LabeledElement(new Canvas.Circle({
          x: 400,
          y: 400,
          radius: 50
        }), {
          position: "over"
        }), SpaceKey)
      },
      MessageBox: {
        "Default": makeTrial(new Canvas.MessageBox(), SpaceKey),
        "One line, lime background": makeTrial(new Canvas.MessageBox({
          content: "Welcome to our task!",
          width: 200,
          background: "lime"
        }), SpaceKey),
        "Multiple lines, lime background": makeTrial(new Canvas.MessageBox({
          content: "Welcome to our task! This is a really cool task! Enjoy!",
          width: 200,
          background: "lime"
        }), SpaceKey)
      },
      Circle: {
        "Default Circle": makeTrial(new Canvas.Circle(), SpaceKey),
        "Green Circle Radius 50": makeTrial(new Canvas.Circle({
          radius: 50,
          fill: "green"
        }), SpaceKey),
        "Green Circle Blue Stroke": makeTrial(new Canvas.Circle({
          radius: 50,
          fill: "green",
          stroke: "blue"
        }), SpaceKey),
        "Centered 100px circle": makeTrial(new Canvas.Circle({
          position: "center",
          radius: 100,
          origin: "center",
          fill: "green"
        }), SpaceKey),
        "Position Test": makeTrial(new Psy.Group((function() {
          var _i, _len, _ref, _results;
          _ref = ["top-left", "top-right", "top-center", "center-left", "center-right", "center", "bottom-left", "bottom-right", "bottom-center"];
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            org = _ref[_i];
            _results.push(new Canvas.Circle({
              position: org,
              radius: 50,
              origin: "center",
              fill: '#' + (Math.random() * 0xFFFFFF << 0).toString(16)
            }));
          }
          return _results;
        })()), SpaceKey),
        "Row of Circles": makeTrial(new Psy.Grid((function() {
          var _i, _results;
          _results = [];
          for (col = _i = 0; _i < 3; col = ++_i) {
            _results.push(new Canvas.Circle({
              position: [0, col],
              radius: 25,
              origin: "center"
            }));
          }
          return _results;
        })(), 1, 3, {
          x: 200,
          y: 200,
          width: 300,
          height: 300
        }), SpaceKey),
        "Column of Circles": makeTrial(new Psy.Grid((function() {
          var _i, _results;
          _results = [];
          for (row = _i = 0; _i < 3; row = ++_i) {
            _results.push(new Canvas.Circle({
              position: [row, 0],
              radius: 25,
              origin: "center"
            }));
          }
          return _results;
        })(), 3, 1, {
          x: 200,
          y: 200,
          width: 300,
          height: 300
        }), SpaceKey)
      },
      Arrow: {
        "Default Arrow": makeTrial(new Canvas.Arrow(), SpaceKey),
        "Blue Arrow, length 200": makeTrial(new Canvas.Arrow({
          length: 200,
          fill: "blue"
        }), SpaceKey),
        "Blue Arrow, black stroke": makeTrial(new Canvas.Arrow({
          length: 200,
          fill: "blue",
          stroke: "black",
          strokeWidth: 4
        }), SpaceKey),
        "Arrow Origin Test": makeTrial(new Psy.Group(_.flatten((function() {
          var _i, _len, _ref, _results;
          _ref = ["top-left", "center", "bottom-right"];
          _results = [];
          for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
            org = _ref[index];
            clrs = ["red", "blue", "green"];
            _results.push([
              new Canvas.Arrow({
                x: 200,
                y: 200,
                origin: org,
                length: 200,
                origin: org,
                fill: clrs[index]
              }), new Canvas.Circle({
                x: 200 * index,
                y: 200 * index,
                fill: "black",
                radius: 5
              })
            ]);
          }
          return _results;
        })())), SpaceKey),
        "Rotating Arrow": makeTrial(new Psy.Sequence((function() {
          var _i, _results;
          _results = [];
          for (i = _i = 0; _i <= 360; i = _i += 2) {
            _results.push(new Canvas.Arrow({
              x: 300,
              y: 300,
              length: 200,
              fill: "black",
              angle: i
            }));
          }
          return _results;
        })(), [40]), SpaceKey),
        "Rotating Arrow no clear": makeTrial(new Psy.Sequence((function() {
          var _i, _results;
          _results = [];
          for (i = _i = 0; _i <= 360; i = _i += 2) {
            _results.push(new Canvas.Arrow({
              x: 300,
              y: 300,
              length: 200,
              fill: "black",
              angle: i,
              opacity: i / 720
            }));
          }
          return _results;
        })(), [40], clear = false), SpaceKey),
        "Position Test": makeTrial(new Psy.Group((function() {
          var _i, _len, _ref, _results;
          _ref = ["top-left", "top-right", "top-center", "center-left", "center-right", "center", "bottom-left", "bottom-right", "bottom-center"];
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            org = _ref[_i];
            _results.push(new Canvas.Arrow({
              position: org,
              length: 50,
              origin: "center",
              fill: '#' + (Math.random() * 0xFFFFFF << 0).toString(16)
            }));
          }
          return _results;
        })()), SpaceKey)
      }
    },
    Media: {
      Picture: {
        "Default Picture": makeTrial(new Canvas.Picture(), SpaceKey),
        "Default Picture Centered": makeTrial(new Canvas.Picture({
          position: "center",
          origin: "center"
        }), SpaceKey),
        "300 X 300": makeTrial(new Canvas.Picture({
          width: 300,
          height: 300
        }), SpaceKey),
        "300 X 300, Red Border": makeTrial(new Canvas.Picture({
          x: 20,
          y: 20,
          width: 300,
          height: 300,
          stroke: "red",
          strokeWidth: 10
        }), SpaceKey),
        "Flicker Two Images 4Hz": makeTrial(new Psy.Sequence([
          new Canvas.Picture({
            url: "images/Sunset.jpg"
          }), new Canvas.Picture({
            url: "images/Shark.jpg"
          })
        ], [250, 250], clear = true, times = 50), SpaceKey),
        "Selectable Set": fromEventSpec({
          CanvasGroup: {
            click: function(node, context, evt) {
              node.find("Image").each(function(shape, n) {
                if (shape.id() === evt.targetNode.id()) {
                  shape.strokeWidth(5);
                  return shape.stroke("red");
                } else {
                  shape.strokeWidth(0);
                  return shape.stroke("");
                }
              });
              return context.draw();
            },
            stims: [
              {
                Picture: {
                  url: "images/Sunset.jpg",
                  x: 5,
                  y: 20,
                  width: 300,
                  height: 300,
                  id: "a"
                }
              }, {
                Picture: {
                  url: "images/Shark.jpg",
                  id: "b",
                  x: 420,
                  y: 20,
                  width: 300,
                  height: 300
                }
              }, {
                Picture: {
                  url: "images/Sunset.jpg",
                  x: 210,
                  y: 350,
                  width: 300,
                  height: 300,
                  id: "c"
                }
              }
            ]
          },
          Next: {
            SpaceKey: ""
          }
        })
      },
      Sound: {
        Default: makeTrial(new Psy.Sound(), SpaceKey)
      }
    },
    HTML: {
      HtmlIcon: {
        Default: makeTrial(new Psy.Html.HtmlIcon(), SpaceKey),
        PercentagePositioning: makeTrial(new Psy.Html.HtmlIcon({
          label: "[50%,50%]",
          x: "40%",
          y: "40%"
        }), SpaceKey)
      },
      HtmlLabel: {
        Default: makeTrial(new Psy.Html.HtmlLabel({
          glyph: "fighter jet"
        }), SpaceKey),
        "Centered Red Label": makeTrial(new Psy.Html.HtmlLabel({
          text: "centered red label",
          position: "center",
          origin: "center",
          color: "red"
        }), SpaceKey),
        "Centered Green Label with glyph": makeTrial(new Psy.Html.HtmlLabel({
          text: "centered green label",
          position: "center",
          glyph: "fighter jet",
          color: " green",
          origin: "center"
        }), SpaceKey)
      },
      HtmlLink: {
        Default: makeTrial(new Psy.Html.HtmlLink(), SpaceKey),
        XYPositioning: makeTrial(new Psy.Html.HtmlLink({
          label: "[100,100]",
          x: 100,
          y: 100
        }), SpaceKey),
        PercentagePositioning: makeTrial(new Psy.Html.HtmlLink({
          label: "[80%,80%]",
          x: "80%",
          y: "80%"
        }), SpaceKey)
      },
      CheckBox: {
        Default: makeTrial(new Psy.Html.CheckBox(), SpaceKey)
      },
      DropDown: {
        Default: makeTrial(new Psy.Html.DropDown(), SpaceKey),
        Countries: makeTrial(new Psy.Html.DropDown({
          choices: ["Canada", "USA", "France", "Germany"],
          name: "Country"
        }), SpaceKey)
      },
      TextField: {
        Default: makeTrial(new Psy.Html.TextField(), ChangeReceiver),
        Centered: makeTrial(new Psy.Html.TextField({
          position: "center"
        }), ChangeReceiver),
        PlaceHolder: makeTrial(new Psy.Html.TextField({
          placeholder: "Hello",
          position: "center"
        }), ChangeReceiver)
      },
      HtmlButton: {
        Default: makeTrial(new Psy.Html.HtmlButton(), SpaceOrTimeout5000),
        PercentagePositioning: makeTrial(new Psy.Html.HtmlButton({
          label: "[80%,80%]",
          x: "80%",
          y: "80%"
        }), SpaceKey),
        CircularButton: makeTrial(new Psy.Html.HtmlButton({
          label: "[50%,50%]",
          x: "50%",
          y: "50%",
          "class": "circular"
        }), SpaceKey),
        "Button over Crosshair": makeTrial(new Psy.Group([
          new Psy.Html.HtmlButton({
            label: "[50%,50%]",
            x: "50%",
            y: "50%",
            "class": "circular huge"
          }), new Canvas.FixationCross()
        ]), SpaceKey)
      },
      HtmlRange: {
        Default: makeTrial(new Psy.Html.HtmlRange(), SpaceKey)
      },
      Slider: {
        Default: makeTrial(new Psy.Html.Slider(), SpaceKey)
      },
      Consent: {
        Default: makeTrial(new Psy.Consent({
          url: "resources/Consent-1.md"
        }), SpaceKey)
      },
      MultiChoice: {
        Default: makeTrial(new Psy.MultiChoice(), SpaceKey),
        Countries: makeTrial(new Psy.MultiChoice({
          choices: ["USA", "Canada", "Mexico", "France"]
        }), SpaceKey),
        Centered: makeTrial(new Psy.MultiChoice({
          choices: ["USA", "Canada", "Mexico", "France"],
          position: "center",
          origin: "center"
        }), SpaceKey)
      },
      Question: {
        DropDown: makeTrial(new Psy.Question({
          name: "Gender",
          choices: ["Male", "Female", "Hermaphrodite"],
          type: "dropdown"
        }), ChangeReceiver),
        MultiChoice: makeTrial(new Psy.Question({
          name: "Gender",
          choices: ["Male", "Female", "Hermaphrodite"],
          type: "multichoice"
        }), ChangeReceiver),
        TextField: makeTrial(new Psy.Question({
          type: "textfield"
        }), ChangeReceiver),
        QuestionGroup: makeTrial(new Psy.Group([
          new Psy.Question({
            name: "Gender",
            choices: ["Male", "Female", "Hermaphrodite"],
            type: "dropdown"
          }), new Psy.Question({
            name: "Gender",
            choices: ["Male", "Female", "Hermaphrodite"],
            type: "multichoice"
          }), new Psy.Question({
            type: "textfield"
          })
        ]), ChangeReceiver)
      },
      Likert: {
        Default: makeTrial(new Psy.Html.Likert(), LikertSelection),
        "With 3 Choices": makeTrial(new Psy.Html.Likert({
          choices: ["Hate", "OK", "Totally Love"]
        }), SpaceKey),
        "With 4 Choices": makeTrial(new Psy.Html.Likert({
          choices: ["Hate", "OK", "Moderately Amusing", "Totally Love"]
        }), SpaceKey),
        "With 4 Choices and Title": makeTrial(new Psy.Html.Likert({
          choices: ["Hate", "OK", "Moderately Amusing", "Totally Love"],
          title: "Rate the movie"
        }), SpaceKey)
      },
      Markdown: {
        "Basic Example": makeTrial(new Psy.Html.Markdown("\nA First Level Header Today tttt\n===================\nA Second Level Header Tday tttt\n---------------------\n### Header 3\n\n\nNow is the time for all good men to come to\nthe aid of their country. This is just a\nregular paragraph.\n\nThe quick brown fox jumped over the lazy\ndog's back.\n\n> This is a blockquote.\n>\n> This is the second paragraph in the blockquote.\n>\n> ## This is an H2 in a blockquote\n\n![alt text](http://www.html5canvastutorials.com/demos/assets/yoda.jpg \"Title\")\n\n"), SpaceKey),
        "An External URL": makeTrial(new Psy.Html.Markdown({
          url: "./resources/page-1.md"
        }), SpaceKey)
      },
      Instructions: {
        "Simple Test": makeTrial(new Psy.Html.Instructions({
          pages: {
            1: {
              Markdown: "Hello"
            },
            2: {
              Markdown: "Goodbye"
            },
            3: {
              Markdown: "Dolly"
            }
          }
        }), Instructions_Done)
      },
      Page: {
        "Test Html": makeTrial(new Psy.Html.Page(), SpaceKey),
        Message: makeTrial(new Psy.Html.Page({
          html: "<div class=\"ui message\">\n  <div class=\"header\">\n    Welcome back!\n  </div>\n  <p>\n    It's good to see you again. I have had a lot to think about since our last visit, I've changed much as a person and I can see that you have too.\n  </p>\n  <p>\n    Perhaps we can talk about it if you have the time.\n  </p>\n</div>\n<div class=\"ui icon message\">\n  <i class=\"inbox icon\"></i>\n  <div class=\"content\">\n  <div class=\"header\">\n    Have you heard about our mailing list?\n  </div>\n  <p>Get all the best inventions in your e-mail every day. Sign up now!</p>\n  </div>\n</div>"
        }), SpaceKey)
      },
      Message: {
        "Default": makeTrial(new Psy.Html.Message(), SpaceKey),
        "Basic Message in Red": makeTrial(new Psy.Html.Message({
          title: "This is a massive message in red",
          content: "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.\nUt enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure\ndolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non\nproident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
          color: "red",
          size: "massive"
        }), SpaceKey),
        "Multiple Messages": makeTrial(new Psy.Group([
          new Psy.Html.Message({
            title: "message 1",
            content: "This is Message 1",
            color: "blue"
          }), new Psy.Html.Message({
            title: "message 2",
            content: "This is Message 2",
            color: "red"
          }), new Psy.Html.Message({
            title: "message 3",
            content: "This is Message 3",
            color: "green"
          })
        ]), SpaceKey),
        "Message and Canvas Rect": makeTrial(new Psy.Group([
          new Psy.Html.Message({
            title: "message 1",
            content: "This is Message 1",
            color: "blue"
          }), new Canvas.FixationCross()
        ]), SpaceKey)
      }
    },
    Dialogs: {
      Prompt: {
        Default: makeTrial(Timeout1000, new Psy.Prompt({
          title: "How old are you?"
        }))
      },
      Confirm: {
        Default: makeTrial(Timeout1000, new Psy.Confirm({
          message: "Do you want to continue?"
        }))
      }
    },
    Collection: {
      Sequence: {
        "Count to Three": makeTrial(new Psy.Sequence([
          new Canvas.Text({
            content: "One",
            position: "center"
          }), new Canvas.Text({
            content: "Two",
            position: "center"
          }), new Canvas.Text({
            content: "Three",
            position: "center"
          })
        ], [1000, 2000, 4000]), SpaceKey),
        "Count to Three with Overlay": makeTrial(new Psy.Sequence([
          new Canvas.Text({
            content: "One",
            position: "center-left"
          }), new Canvas.Text({
            content: "Two",
            position: "center"
          }), new Canvas.Text({
            content: "Three",
            position: "center-right"
          })
        ], [1000, 2000, 4000], clear = false), SpaceKey),
        "Fast Countdown": makeTrial(new Psy.Sequence((function() {
          var _i, _results;
          _results = [];
          for (i = _i = 50; _i >= 0; i = --_i) {
            r = i * 4;
            g = 255 - (i * 4);
            b = i;
            _results.push(new Canvas.Text({
              content: i,
              position: "center",
              fontSize: 80 + i * 2,
              fill: "rgb(" + r + "," + g + "," + b + ")"
            }));
          }
          return _results;
        })(), [80]), SpaceKey),
        "Repeating Squares": makeTrial(new Psy.Sequence([
          new Canvas.Rectangle({
            position: [2, 2],
            width: 80,
            height: 80,
            fill: "red",
            layout: gridlayout
          }), new Canvas.Rectangle({
            position: [2, 3],
            width: 80,
            height: 80,
            fill: "blue",
            layout: gridlayout
          }), new Canvas.Rectangle({
            position: [2, 4],
            width: 80,
            height: 80,
            fill: "yellow",
            layout: gridlayout
          })
        ], [100], true, 9), SpaceKey)
      }
    },
    NeuroPsych: {
      TrailsA: {
        "Default": makeTrial(new Psy.TrailsA(), new Psy.Receiver({
          id: "trail_completed"
        }))
      }
    },
    Tasks: {
      "Arrow Flanker": function() {
        return "../arrow_flanker_index.html";
      }
    },
    Response: null
  };

  this.activeTrial = null;

  this.autostart = true;

  this.startTrial = function($el, subels, trial) {
    context.clearContent();
    return trial.start(context, function() {
      var $elnext;
      console.log("calling back");
      if (this.autostart) {
        $elnext = $el.next();
        console.log("next el", $elnext);
        console.log("next el text is", $elnext.text().trim());
        console.log("next el text length", $elnext.text().trim().length);
        console.log("first sibling text is", $el.siblings().first().text().trim());
        if ($elnext.text().trim().length === 0) {
          return selectTest($el.siblings().first(), subels);
        } else {
          return selectTest($elnext, subels);
        }
      }
    });
  };

  this.selectTest = function($el, subels) {
    var key, trial;
    key = $el.text().trim();
    $el.addClass("active");
    $el.siblings().removeClass("active");
    trial = subels[key];
    if (this.activeTrial) {
      this.activeTrial.stop();
    }
    this.activeTrial = trial();
    if (this.autostart) {
      return startTrial($el, subels, this.activeTrial);
    }
  };

  window.updateTests = function(category, name) {
    var key, subels, testlist, value;
    subels = testSet[category][name];
    testlist = $("#testmenu");
    testlist.children().remove();
    for (key in subels) {
      value = subels[key];
      testlist.append("<a href='#' class=\"item\" id=" + key + "> " + key + "</a>");
    }
    return $("#testmenu > a").click(function(e) {
      var $this;
      $this = $(this);
      selectTest($this, subels);
      context.clearContent();
      return $("#start").click((function(_this) {
        return function(e) {
          context.clearContent();
          if (_this.activeTrial != null) {
            return _this.activeTrial.start(context, function() {
              console.log("calling back");
              if (this.autostart) {
                return selectTest($this.next(), subels);
              }
            });
          }
        };
      })(this));
    });
  };

  $(document).ready((function(_this) {
    return function() {
      var $el, categories, item, key, skey, svalue, value;
      _this.autostart = $("#checkid").is(":checked");
      categories = $("#compmenu");
      for (key in testSet) {
        value = testSet[key];
        $el = $("<div class=\"header item category\" id=" + key + "> " + key + " </div>");
        categories.append($el);
        for (skey in value) {
          svalue = value[skey];
          item = $("<a href='#' class=\"item\" id=" + skey + "> " + skey + "</a>");
          item.addClass("compitem");
          categories.append(item);
        }
      }
      $("#checkid").on("click", function(e) {
        console.log("enable");
        console.log($(this));
        return console.log(this.checked);
      });
      return $("#compmenu >  a").click(function(e) {
        var category, menu, name;
        console.log("clicked menu item");
        menu = $("#compmenu > a");
        console.log("cur", menu);
        console.log("children", menu.children());
        console.log("this", $(this));
        console.log("compitem", $(".compitem"));
        $(this).addClass("active");
        $(this).siblings().removeClass("active");
        console.log("number of siblings", $(this).siblings(".header.item").length);
        console.log("prevAll", $(this).prevAll(".category").first().text());
        category = $(this).prevAll(".category").first().text().trim();
        name = $(this).text().trim();
        name = name.replace(/\s+/g, "");
        console.log("name", name);
        console.log("category", category);
        return updateTests(category, name);
      });
    };
  })(this));

}).call(this);
