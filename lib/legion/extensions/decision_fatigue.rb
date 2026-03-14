# frozen_string_literal: true

require 'legion/extensions/decision_fatigue/version'
require 'legion/extensions/decision_fatigue/helpers/constants'
require 'legion/extensions/decision_fatigue/helpers/decision_record'
require 'legion/extensions/decision_fatigue/helpers/fatigue_engine'
require 'legion/extensions/decision_fatigue/runners/decision_fatigue'

module Legion
  module Extensions
    module DecisionFatigue
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
