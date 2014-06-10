
factorSet =
  condition:
    levels: ["congruent", "incongruent"]


colors = ["red", "green", "blue", "yellow"]


factorNode = Psy.FactorSetNode.build(factorSet)

# create 5 blocks of trials with 5 complete replications per block
@trials = factorNode.trialList(5, 5)



@trials = @trials.bind (record) ->
  color = Psy.oneOf(colors)
  word: Psy.match record.condition,
    congruent: color.toUpperCase()
    incongruent: Psy.oneOf(colors.exclude(color)).toUpperCase()
  color: color


@trials.shuffle()
@context = Psy.createContext()

console.log(@trials)


window.display =
  Display:

    Prelude:
      Events:
        1:
          Markdown: """

          Welcome to the Experiment!
          ==========================

          This a simple task.

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

      Background:
        Blank:
          fill: "black"

      Events:
        1:
          FixationCross:
            fill: "green"
          Next:
            Timeout:
              duration: 1000
        2:
          Group:
            stims: [
              Text:
                position: "center"
                origin: "center"
                content: @trial.word
                fill: @trial.color
            ,
              ButtonGroup$buttonset:
                labels: ["red", "green", "blue", "yellow"]
                x: 280
                y: 500
            ]

          Next:
            Receiver$buttonset:
              signal: "clicked"

      Feedback:  ->

        Blank:
          opacity: .1
        Next:
          Timeout:
            duration: 200

#Coda:
#  Events:
#    1:
#      Text:
#        position: "center"
#        origin: "center"
#        content: "The End"
#        fontSize: 200
#
#      Next:
#        Timeout: duration: 5000




pres = new Psy.Presenter(trials, display.Display, context)
pres.start()

