module Permissioner
  module Matchers
    class ExactlyAllowActions

      def initialize(controller, expected_actions)
        @controller = controller.to_s
        @expected_actions = Array(expected_actions).collect { |action| action.to_s }
      end

      def matches?(permission_service)
        expected_actions_exactly_match? all_allowed_actions(permission_service) 
      end

      def failure_message_for_should(permission_service)
        "expected that for \"#{@controller.capitalize}Controller\" exactly actions\n" \
        "#{@expected_actions} are allowed, but found actions\n"\
        "#{all_allowed_actions(permission_service).keys.collect { |e| e[1] } } allowed"
      end

      private

      def expected_actions_exactly_match?(all_allowed_actions)
        if @expected_actions == ['all']
          all_allowed_actions.include?([@controller, 'all'])
        else
          allowed_actions_for_controller(all_allowed_actions).count == @expected_actions.count && all_expected_actions_allowed?(all_allowed_actions)
        end
      end

      def all_allowed_actions(permission_service)
        @all_allowed_actions ||= begin
          permission_service.instance_variable_get(:@allowed_actions) || []
        end
      end

      def allowed_actions_for_controller(all_allowed_actions)
        all_allowed_actions.keys.inject([]) do |allowed_actions, e|
          allowed_actions << e[1] if e[0] == @controller end.uniq
      end

      def all_expected_actions_allowed?(all_allowed_actions)
        @expected_actions.all? { |action| all_allowed_actions[[@controller, action]] }
      end

    end
  end
end