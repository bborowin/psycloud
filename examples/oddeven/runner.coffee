@context = new Psy.createContext()
_ = Psy._



factorSet =
  oddeven:
    levels: ["odd", "even"]


@evenSampler = new Psy.ReplacementSampler([2,4,6,8])
@oddSampler = new Psy.ReplacementSampler([3,5,7,9])


fnode = Psy.FactorSetNode.build(factorSet)
@trials = fnode.trialList(5, 5)

trials = @trials.bind ((record) =>
  if record.oddeven is "odd" then num: oddSampler.take(1) else num: evenSampler.take(1))

trials.shuffle()


nums = [2,3,4,5,6,7,8,9]



window.display =
  Display:
    Prelude:
      Events:
        1:
          Markdown: """

          Welcome to the Experiment!
          ==========================

          This a simple task.

          On every trial a number single-digit number will appear on the screen.

            * If the number is even press the 'n' key

            * If the number is odd press the 'm' key

            * If your response is correct, you will will get a "Correct!" message, otherwise you will get an "Incorrect!" message.

          Press any key to continue
          -------------------------

          """
          Next:
            AnyKey: ""


    Block:
      Start: (context) ->
        Text:
          position: "center"
          origin: "center"
          content: ["Get Ready!", "Press Space Bar to start"]
        Next:
          SpaceKey: ""

      End: (context) ->
        Text:
          position: "center"
          origin: "center"
          content: "END OF BLOCK, PRESS ANY KEY TO CONTINUE"
        Next:
          AnyKey: ""



    Trial: ->
      #num = if @oddeven is "even" then evenSampler.take(1) else oddSampler.take(1)

      Background:
        CanvasBorder:
          stroke: "black"

      Events:
        1:
          FixationCross:
            stroke: "green"
          Next:
            Timeout:
              duration: 500
        2:
          Text:
            content: @num
            position: "center"
            origin: "center"
            fontSize: 175
            fill: "blue"
          Next:
            KeyPress:
              id: "answer"
              keys: ['n', 'm']
              correct: if @oddeven is "even" then 'n' else 'm'


      Feedback: ->
        console.log("in feedback")
        console.log("this", this)
        console.log("accuracy", @Accuracy)
        console.log("RT", @RT)
        #HtmlLabel:
        #  text: if @Accuracy is true then "CORRECT" else "INCORRECT"
        #  glyph: if @Accuracy is true then "checkmark" else "frown"
        #  position: "center"
        #  origin: "center"
        Rectangle:
          fill: if @Accuracy then "green" else "red"
          x: 0
          y: 0
          width: 960
          height: 800
          opacity: .1
        Next:
          Timeout:
            duration: 200








window.pres = new Psy.Presenter(trials, display.Display, context)
console.log("STARTING PRES")
pres.start()
###