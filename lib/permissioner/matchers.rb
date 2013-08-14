require 'permissioner/matchers/exactly_allow_actions'
require 'permissioner/matchers/exactly_allow_attributes'
require 'permissioner/matchers/exactly_allow_controllers'
require 'permissioner/matchers/exactly_allow_resources'


RSpec::Matchers.define :allow_attribute do |*args|
  match do |permission_service|
    permission_service.allow_attribute?(*args)
  end
end

RSpec::Matchers.define :pass_filters do |*args|
  match do |permission_service|
    permission_service.passed_filters?(*args)
  end
end

module Permissioner
  module Matchers

    RSpec::Matchers.define :allow_action do |*args|
      match do |permission_service|
        permission_service.allow_action?(*args)
      end
    end

    def exactly_allow_actions(*expected_actions)
      ExactlyAllowActions.new(*expected_actions)
    end

    def exactly_allow_attributes(*expected_attributes)
      ExactlyAllowAttributes.new(*expected_attributes)
    end

    def exactly_allow_controllers(*expected_controllers)
      ExactlyAllowControllers.new(*expected_controllers)
    end

    def exactly_allow_resources(*expected_resources)
      ExactlyAllowResources.new(*expected_resources)
    end

  end
end