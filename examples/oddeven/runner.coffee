@context = new Psy.createContext()
_ = Psy._



factorSet =
  oddeven:
    levels: ["odd", "even"]


@evenSampler = new Psy.ReplacementSampler([2,4,6,8])
@oddSampler = new Psy.ReplacementSampler([3,5,7,9])

fnode = Psy.FactorSetNode.build(factorSet)

# create 5 blocks of trials with 5 complete replications per block
@trials = fnode.trialList(5, 5)

# add a column to design called 'num' that contains the odd or even numerals
trials = @trials.bind ((record) =>
  if record.oddeven is "odd" then num: oddSampler.take(1)[0] else num: evenSampler.take(1)[0])

trials.shuffle()


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
      Start: ->
        Text:
          position: "center"
          origin: "center"
          content: ["Get Ready for Block #{@blockNumber} of #{context.numBlocks}!", "Press Space Bar to start"]
        Next:
          SpaceKey: ""

      End: ->
        console.log("Block end", this)
        console.log("answer Accuracy", @answer.Accuracy)
        Text:
          position: "center"
          origin: "center"
          content: ["End of Block #{@blockNumber}", "Press any key to continue"]
        Next:
          AnyKey: ""



    Trial: ->

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
            First:
              KeyPress:
                id: "answer"
                keys: ['n', 'm']
                correct: if @oddeven is "even" then 'n' else 'm'
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



pres = new Psy.Presenter(trials, display.Display, context)
pres.start()
