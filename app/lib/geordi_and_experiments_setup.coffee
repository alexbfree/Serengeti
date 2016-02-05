ExperimentServerClient = require 'lib/experiments'

Subject = require 'models/subject'
User = require 'zooniverse/lib/models/user'
GeordiClient = require 'zooniverse-geordi-client'

checkZooUserID = ->
  if User.current?.zooniverse_id?
    User.current?.zooniverse_id?
  else
    Geordi.UserStringGetter.ANONYMOUS

checkZooSubject = ->
  Subject.current?.zooniverseId

Geordi = new GeordiClient({
  "server": "production"
  "projectToken": "serengeti"
  "zooUserIDGetter": checkZooUserID
  "subjectGetter": checkZooSubject
})

ExperimentServer = new ExperimentServerClient(Geordi)

Geordi.experimentServerClient = ExperimentServer

module.exports = Geordi

