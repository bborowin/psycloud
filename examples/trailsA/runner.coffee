@context = new Psy.createContext()
_ = Psy._



factorSet =
  trial: [1,2,3]

console.log("building factorSet")
fnode = Psy.FactorSetNode.build(factorSet)

# create 1 blocks of trials with 1 complete replications per block
console.log("constructing trial list")
@trials = fnode.trialList(1,1)



window.display =
  Display:

    Prelude:
      Events:
        1:
          Markdown: """

          Trails
          ==========================

          This a trail-making task.

          On every trial a number of cirlces will appear on the screen.
          Each circle will have a number inside it. Your goal is to make a trail linking all the numbered circles.
          The path you make should be in sequential order: 1, 2, 3 .. all the way to 25.

          To make a path between two circles, simply click the next circle in the path.
          When you select the correct circle, it will turn yellow. When you complete the trail, the final circle will turn red.


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
          content: ["Get Ready!", "Press Space Bar to start"]
        Next:
          SpaceKey: ""

    Trial: ->
      Background:
        Blank:
          fill: "gray"
        CanvasBorder:
          stroke: "black"

      Events:
        1:
          TrailsA:
            npoints: 25
          Next:
            Receiver:
              id: "trail_completed"

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
