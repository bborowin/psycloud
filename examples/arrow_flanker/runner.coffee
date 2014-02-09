@context = new Psy.createContext()
_ = Psy._



factorSet =
  flanker:
    levels: ["congruent", "incongruent"]
  centerArrow:
    levels: ["left", "right"]


fnode = Psy.FactorSetNode.build(factorSet)

# create 5 blocks of trials with 5 complete replications per block
@trials = fnode.trialList(5, 5)


@trials = @trials.bind ((record) =>
  flankerArrow: Psy.match record.flanker,
      congruent: record.centerArrow
      incongruent: -> Psy.match record.centerArrow,
          left: "right"
          right: "left"

  )



console.log("trials", @trials)


@trials.shuffle()


window.display =
  Display:

    Prelude:
      Events:
        1:
          Markdown: """

          Welcome to the Experiment!
          ==========================

          On every trial a central arrow will appear surrounded by arrows on either side.
          Your goal is to focus on the central arrow and decide whether it points left or right.

            * If the central arrow points <-- left, press the 'g' key.

            * If the central arrow points --> right, press the 'h' key.

            * If your response is correct, the screen will briefly turn green.

            * If your response is incorrect, the screen will briefly turn red.

            * make your decision as fast as you can.

          Press any key to continue
          -------------------------

          """
          Next:
            AnyKey: ""

    Block:
      Start: ->
        console.log("START BLOCK")
        Text:
          position: "center"
          origin: "center"
          content: ["Get Ready for Block #{@blockNumber}!", "Press Space Bar to start"]
        Next:
          SpaceKey: ""

      End: ->
        console.log("END BLOCK")
        Text:
          position: "center"
          origin: "center"
          content: ["End of Block #{@blockNumber}", "Press any key to continue"]
        Next:
          AnyKey: ""

    Trial: ->
      arrowLen = 175

      Background:
        Blank:
          fill: "white"
        CanvasBorder:
          stroke: "black"


      Events:
        1:
          FixationCross:
            fill: "gray"
          Next:
            Timeout:
              duration: 1000
        2:
          Group:
            stims: [
              Arrow:
                x: @screen.center.x - 2*arrowLen - 20
                y: @screen.center.y
                thickness: 35
                arrowSize: 75
                origin: "center"
                fill: "black"
                length: arrowLen
                direction: @trial.flankerArrow
            ,

              Arrow:
                x: @screen.center.x - arrowLen - 10
                y: @screen.center.y
                thickness: 35
                arrowSize: 75
                origin: "center"
                fill: "black"
                length: arrowLen
                direction: @trial.flankerArrow
                #height: diameter
            ,
              Arrow:
                x: @screen.center.x
                y: @screen.center.y
                thickness: 35
                arrowSize: 75
                origin: "center"
                fill: "black"
                length: arrowLen
                direction: @trial.centerArrow

            ,
              Arrow:
                x: @screen.center.x + arrowLen + 10
                y: @screen.center.y
                thickness: 35
                arrowSize: 75
                origin: "center"
                fill: "black"
                length: arrowLen
                direction: @trial.flankerArrow
            ,
              Arrow:
                x: @screen.center.x + 2*arrowLen + 20
                y: @screen.center.y
                thickness: 35
                arrowSize: 75
                origin: "center"
                fill: "black"
                length: arrowLen
                direction: @trial.flankerArrow

            ]

          Next:
            First:
              KeyPress:
                id: "answer"
                keys: ['g', 'h']
                correct: if @trial.centerArrow is "left" then 'g' else 'h'
              Timeout:
                id: "timeout"
                duration: 1500
      Feedback: ->
        Blank:
          fill: if @answer?.Accuracy then "green" else "red"
          opacity: .1
        Next:
          Timeout:
            duration: 200

    Coda:
      Events:
        1:
          Text:
            position: "center"
            origin: "center"
            content: "The End"
            fontSize: 200

          Next:
            Timeout: duration: 5000






pres = new Psy.Presenter(trials, display.Display, context)
pres.start()
