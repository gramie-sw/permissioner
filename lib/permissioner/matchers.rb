module Permissioner
  class MatchersHelper

  end
end


RSpec::Matchers.define :allow_action do |*args|
  match do |permission_service|
    permission_service.allow_action?(*args)
  end
end

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

RSpec::Matchers.define :exactly_allow_controllers do |*controllers|
  match do |permission_service|
    if controllers.any?
      allowed_actions = permission_service.instance_variable_get(:@allowed_actions)
      if allowed_actions
        @allowed_controllers = allowed_actions.keys.collect { |e| e.first }.uniq
        next (@allowed_controllers.count == controllers.count &&
            controllers.all? { |c| @allowed_controllers.include? c.to_s })
      else
        next false
      end
    end
    true
  end
end

RSpec::Matchers.define :exactly_allow_actions do |controller, actions|
  match do |permission_service|
    actions = Array(actions)
    if actions.any?
      allowed_actions = permission_service.instance_variable_get(:@allowed_actions)
      if allowed_actions
        next (allowed_actions.keys.inject(0) { |count, b| b.first == controller.to_s ? count+1 : count } == actions.count &&
            actions.all? { |action| allowed_actions[[controller.to_s, action.to_s]] })
      else
        next false
      end
    end
    true
  end
end

RSpec::Matchers.define :exactly_allow_attributes do |resource, attributes|
  match do |permission_service|
    attributes = Array(attributes)
    if attributes.any?
      all_allowed_attributes = permission_service.instance_variable_get(:@allowed_attributes)
      if all_allowed_attributes
        allowed_attributes = all_allowed_attributes[resource]
        next allowed_attributes.count == attributes.count &&
            attributes.all? {|attribute| allowed_attributes.include? attribute}
      else
        next false
      end
    end
    true
  end
end

