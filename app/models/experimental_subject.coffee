Subject = require('models/subject')

class ExperimentalSubject extends Subject
  @next: (callback) ->
    console.log this instanceof ExperimentalSubject
    debugger
    


module.exports = ExperimentalSubject



