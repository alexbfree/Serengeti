$ = require('jqueryify')
User = require 'zooniverse/lib/models/user'
ExperimentalSubject = require 'models/experimental_subject'
AnalyticsLogger = require 'lib/analytics'

# CONSTANTS #

###
Define the active experiment here by using a string which exists in http://experiments.zooniverse.org/active_experiments
If no experiments should be running right now, set this to null, false or ""
###
ACTIVE_EXPERIMENT = "SerengetiInterestingAnimalsExperiment1"

###
When an error is encountered from the experiment server, this is the period, in milliseconds, that the code below will
  wait before any further attempts to contact it.
###
RETRY_INTERVAL = 300000 # (5 minutes) #

# VARIABLES #

###
Do not modify this variable initialization, it is used to keep track of when the last experiment server failure was
###
lastFailedAt = null

###
This method will contact the experiment server to find the cohort and any other experimental state for this user in the specified experiment
###
getExperimentState = (user_id = User.current?.zooniverse_id) ->
  eventualData = new $.Deferred
  if ACTIVE_EXPERIMENT?
    now = new Date().getTime()
    if lastFailedAt?
      timeSinceLastFail = now - lastFailedAt.getTime()
    if lastFailedAt == null || timeSinceLastFail > RETRY_INTERVAL
      try
        $.get('http://experiments.zooniverse.org/experiment/' + ACTIVE_EXPERIMENT + '?userid=' + user_id)
        .then (data) =>
          eventualData.resolve data
        .fail =>
          lastFailedAt = new Date()
          AnalyticsLogger.logError "500", "Couldn't retrieve experimental split data", "error"
          eventualData.resolve null
      catch error
        eventualData.resolve null
    else
      eventualData.resolve null
  else
    eventualData.resolve null
  eventualData.promise()

exports.getExperimentState = getExperimentState
exports.ACTIVE_EXPERIMENT = ACTIVE_EXPERIMENT
