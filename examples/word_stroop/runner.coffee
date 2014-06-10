
factorSet =
  condition:
    levels: ["congruent", "incongruent", "neutral"]

wordItems = ["and", "that", "how", "where", "the", "which"]
numberItems = ["one", "two", "three"]
numbers = [1,2,3]
numberMap = { 1: "one", 2: "two", 3: "three"}

fnode = Psy.FactorSetNode.build(factorSet)

# create 5 blocks of trials with 5 complete replications per block
@trials = fnode.trialList(5, 5)



@trials = @trials.bind (record) ->
  number = Psy.oneOf(numbers)
  ret =
    word: Psy.match record.condition,
      congruent: numberMap[number]
      incongruent: numberMap[Psy.sample(numbers.exclude(number), 1)[0]]
      neutral: Psy.sample(wordItems, 1)[0]
    number: number

  ret.text =  Psy.rep(ret.word, ret.number).join(" ")
  ret


@trials.shuffle()
@context = Psy.createContext()


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
          fill: "gray"
        CanvasBorder:
          stroke: "black"

      Events:
        1:
          FixationCross:
            fill: "black"
          Next:
            Timeout:
              duration: 1000
        2:
          Text:
            position: "center"
            origin: "center"
            content: @trial.text

          Next:
            KeyPress:
              id: "answer"
              keys: ['1', '2', '3']
              correct: if @trial.number is 1 then '1' else if @trial.number is 2 then '2' else '3'
              timeout: 2500

      Feedback:  ->
        console.log("Feedback this", this)
        Blank:
          fill: if @answer.accuracy then "green" else "red"
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

