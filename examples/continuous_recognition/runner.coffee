_ = Psy._

console.log("loading table")
@table = Psy.loadTable("./test_design.csv")
console.log("table loaded")

@splitTable = @table.splitBy(@table["block"])
console.log(splitTable)

@trialList = Psy.TrialList.fromBlockArray(_.values(splitTable))
console.log(trialList)

@context = Psy.createContext()

window.display =
  Display: ->

    Define:
      responseCount: 0
      numCorrect: 0
      numWrong: 0
      demographics: {
        age: 0
        gender: ""
        education: ""
        ethnicity: ""
      }


    Prelude:
      Events:
        1:
          Consent:
            url: "./instructions/Consent-1.md"
          Next:
            Receiver:
              signal: "consent"
        2:
          Group:
            stims:
              1: Question:
                type: "textfield"
                question: "What is your current age in years?"
                react:
                  change: (arg) => @set("demographics.age", arg.val)
                    #@update("demographics", (x) -> x.age = arg.val; x)
                    #console.log(@get("demographics"))
              2: Question:
                question: "What is your gender?"
                type: "dropdown"
                choices: ["Male", "Female"]
                name: "Gender"
                react:
                  change: (arg) => @set("demographics.gender",arg.val)

              3: Question:
                question: "How many years of education?"
                type: "textfield"
                react:
                  change: (arg) => @set("demographics.education",arg.val)

              4: Question:
                question: "What is your ethnicity?"
                type: "textfield"
                react:
                  change: (arg) => @set("demographics.ethnicity",arg.val)

              5: HtmlButton:
                  id: "submit_button"
                  label: "Submit"
                  react:
                    clicked: (arg) =>
                      console.log("received clicked", arg)
                      console.log("demographics: ", @get("demographics"))

          Next:
            Receiver:
              id: "submit_button"
              signal: "clicked"
        3:
          Instructions:
            pages:
              1: Markdown: url: "./instructions/Instructions-1.md"
              2: Markdown: url: "./instructions/Instructions-2.md"
          Next:
            Receiver: signal: "done"

    Block:
      Start: ->

        Text:
          position: "center"
          origin: "center"
          content: ["Get Ready for Block #{@blockNumber}!", "Press Space Bar to start"]
        Next:
          SpaceKey: ""

      End:  ->
        numCorrect = @context.get("numCorrect")
        numWrong = @context.get("numWrong")

        percentCorrect = numCorrect/(numCorrect+numWrong) * 100

        Text:
          position: "center"
          origin: "center"
          content: ["End of Block #{@blockNumber}", "Press any key to continue", "Performance eon last block #{percentCorrect}"]
        Next:
          AnyKey: ""

    Trial: ->

      Background:
        Blank:
          fill: "white"
        CanvasBorder:
          stroke: "black"

      Events:
        1:
          FixationCross:
            fill: "gray"
          #Next:
          #  Timeout:
          #    duration: 500
        2:
          Picture:
            url: @trial.image
            position: "center"
            origin: "center"

          Next:
            KeyPress:
              id: "answer"
              keys: ['g', 'h']
              correct: if @trial.condition is "old" then 'g' else 'h'
              timeout: 2000

      Feedback: ->
        numCorrect = @context.get("numCorrect")
        numWrong = @context.get("numWrong")

        if @answer.accuracy
          numCorrect += 1
          @context.set("numCorrect", numCorrect)
        else
          numWrong += 1
          @context.set("numWrong", numWrong)

        #Blank:
        #  fill: if @answer.Accuracy then "green" else "red"
        #  opacity: .1
        Text:
          content: numCorrect/(numCorrect+numWrong)
          fontSize: 75
          position: "center"
        Next:
          Timeout:
            duration: 100

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





disp = display.Display.call(context)
pres = new Psy.Presenter(trialList, disp, context)
pres.start()
