Subject = require('models/subject')

class ExperimentalSubject extends Subject

  @othermethod: ->
    "hello"
    
  @next: (callback) ->
    console.log @
    console.log @othermethod()
    debugger



module.exports = ExperimentalSubject



