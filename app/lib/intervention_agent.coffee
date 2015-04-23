User = require 'zooniverse/lib/models/user'
Experiments = require 'lib/experiments'
$ = require('jqueryify')

class InterventionAgent
  constructor: (userID, experiment, cohort, data) ->
    @userID = userID
    @experiment = experiment
    @cohort = cohort
    @data = data

  #TODO rewrite for new API
  getUserProfile: (scoreType) ->
    if scoreType == "interestInSpecies"
      Experiments.SPECIES_INTEREST_PROFILES[@userID]
    else
      []

class ControlAgent extends InterventionAgent
  constructor: ->
    @userID = User.current?.zooniverse_id
    @experiment = Experiments.ACTIVE_EXPERIMENT
    @cohort = 'control'
    @data = null

class InterestingAgent extends InterventionAgent
  constructor: ->
    @userID = User.current?.zooniverse_id
    @experiment = Experiments.ACTIVE_EXPERIMENT
    @cohort = 'interesting'
    profile = @getUserProfile "interestInSpecies"
    @data = {
      profile: profile
      experimentState: Experiments.getExperimentState @userID
    }

exports.agents = {
  'control': new ControlAgent()
  'interesting': new InterestingAgent()
}

exports.InterventionAgent = InterventionAgent
exports.ControlAgent = ControlAgent
exports.InterestingAgent = InterestingAgent