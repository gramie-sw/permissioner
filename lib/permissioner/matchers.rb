require 'permissioner/matchers/exactly_allow_actions'
require 'permissioner/matchers/exactly_allow_attributes'
require 'permissioner/matchers/exactly_allow_controllers'
require 'permissioner/matchers/exactly_allow_resources'


RSpec::Matchers.define :allow_attribute do |*args|
  match do |permission_service|
    permission_service.allow_attribute?(*args)
  end
end

RSpec::Matchers.define :pass_filters do |controller, action, params={}|
  match do |permission_service|
    permission_service.passed_filters?(controller, action, params)
  end
end

module Permissioner
  module Matchers

    RSpec::Matchers.define :allow_action do |*args|
      match do |permission_service|
        permission_service.allow_action?(*args)
      end
    end

    def exactly_allow_actions(resource, expected_attributes)
      ExactlyAllowActions.new(resource, expected_attributes)
    end

    def exactly_allow_attributes(resource, expected_actions)
      ExactlyAllowAttributes.new(resource, expected_actions)
    end

    def exactly_allow_controllers(*expected_controllers)
      ExactlyAllowControllers.new(*expected_controllers)
    end

    def exactly_allow_resources(*expected_resources)
      ExactlyAllowResources.new(*expected_resources)
    end

  end
end