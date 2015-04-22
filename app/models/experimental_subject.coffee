Subject = require('models/subject')
User = require 'zooniverse/lib/models/user'
Experiments = require 'lib/experiments'

class ExperimentalSubject extends Subject
  @agent = null

  # get the next subject IDs for the specified user ID from the experiment server	(assumes "interesting" cohort)
  @getNextSubjectIDs: (numberOfSubjects) ->
    debugger
    userID = User.current?.zooniverse_id
    subjectIDsFetcher = new $.Deferred
    try
      $.get('http://experiments.zooniverse.org/experiment/' + ACTIVE_EXPERIMENT + '/participant/' + userID + '/next/'+numberOfSubjects)
      .then (data) =>
        subjectIDsFetcher.resolve data
      .fail =>
        AnalyticsLogger.logError "500", "Couldn't retrieve next subjects", "error"
        subjectIDsFetcher.resolve null
    catch error
      subjectIDsFetcher.resolve null
    subjectIDsFetcher.promise()

  # get a specific subject by ID from the API and instantiate it as a model
  @subjectFetch: (subjectID) =>
    subjectFetcher = new $.Deferred

    getter = Api.get("/projects/serengeti/subjects/#{subjectID}").deferred

    getter.done (rawSubject) =>
      subjectFetcher.resolve (@fromJSON rawSubject)

    getter.fail ->
      subjectFetcher.resolve null

    subjectFetcher.promise()

  # for interesting cohort users, we will show a selection of known interesting and random unknown subjects.
  @next: (callback) ->
    debugger
    if Experiments.ACTIVE_EXPERIMENT?
      @current.destroy() if @current?
      count = @count()

      # Prepare one "current" and fill the rest of the queue.
      toFetch = (@queueLength - count) + 1
      if toFetch >= 1
        fetcher = new $.Deferred
        @getNextSubjectIDs toFetch
          .then(data) ->
            debugger
            if subjectIDs?
               for subjectID in subjectIDs
                  if subjectID=="RANDOM"
                    @fetch 1
                  else
                    @subjectFetch subjectID
      if count is 0
        nexter = fetcher.then () =>
          first = @first()
          first?.destroy() if first?.metadata.empty

          if @count() is 0
            @trigger 'no-subjects'
          else
            @first().select()
      else
        nexter = new $.Deferred
        nexter.done =>
          @first().select()

        nexter.resolve()

      nexter.then callback

      nexter

module.exports = ExperimentalSubject
