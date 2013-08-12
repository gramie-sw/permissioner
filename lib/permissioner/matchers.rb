require 'permissioner/matchers/exactly_allow_controllers'
require 'permissioner/matchers/exactly_allow_actions'


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


RSpec::Matchers.define :exactly_allow_actions do |controller, expected_actions|

  define_method :count_allowed_actions do
    @all_allowed_actions.keys.inject(0) { |count, b| b.first == controller ? count+1 : count }
  end

  define_method :all_given_actions_allowed? do
    expected_actions.all? { |action| @all_allowed_actions[[controller, action]] }
  end

  define_method :actions_exactly_match? do
    if expected_actions == ['all']
      @all_allowed_actions.include?([controller, 'all'])
    else
      count_allowed_actions == expected_actions.count && all_given_actions_allowed?
    end
  end

  match do |permission_service|
    controller = controller.to_s
    expected_actions = Array(expected_actions).collect { |action| action.to_s }

    @all_allowed_actions = permission_service.instance_variable_get(:@allowed_actions)
    @all_allowed_actions && actions_exactly_match?

  end

  failure_message_for_should do
    "expected that for \"#{controller.capitalize}Controller\" exactly actions\n" \
    "#{expected_actions} are allowed, but found actions\n"\
    "#{@all_allowed_actions.keys.collect { |e| e[1] } if @all_allowed_actions} as allowed"\
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
            attributes.all? { |attribute| allowed_attributes.include? attribute }
      else
        next false
      end
    end
    true
  end
end

