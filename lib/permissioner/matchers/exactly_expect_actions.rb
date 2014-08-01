module Permissioner
  module Matchers
    class ExactlyExpectActions

      def initialize(actions_instance_var, *all_expected_actions)
        @all_expected_actions = all_expected_actions.collect do |value|
          raise 'multiple actions for a controller must stated as array, e.g. [:new, :create]' if value.size > 2
          [value[0].to_s, Array(value[1]).collect! { |e| e.to_s }]
        end
        @failing_actions = []
        @actions_instance_var = actions_instance_var
      end

      def matches?(permission_service)
        @permission_service = permission_service
        expected_actions_exactly_match?
      end

      def failure_message
        if @failing_actions.empty?
          "expected to find actions for controllers \n" \
          "#{all_expected_controllers}, but found actions for controllers\n"\
          "#{all_actuel_controllers}"
        else
          message = "expected actions did not match for following controllers:\n"
          @failing_actions.inject(message) do |msg, value|
            msg +=
                "#{value[0]}:\n"\
                "#{value[1]} were expected but found actions\n"\
                "#{actual_actions_for_controller(value[0])}\n"
            msg
          end
        end
      end

      def  failure_message_when_negated
        'given actions are exactly match although this is not expected'
      end

      private

      def expected_actions_exactly_match?
        controllers_exactly_match? && actions_exactly_match?
      end

      def controllers_exactly_match?
        all_actuel_controllers == all_expected_controllers
      end

      def actions_exactly_match?
        @all_expected_actions.each do |controller, expected_actions_for_controller|
          expected_actions_for_controller.sort!
          match = actions_for_controller_exactly_match?(controller, expected_actions_for_controller)
          @failing_actions << [controller, expected_actions_for_controller] unless match
          match
        end
        @failing_actions.empty?
      end

      def actions_for_controller_exactly_match?(controller, expected_actions_for_controller)
        if expected_actions_for_controller == ['all']
          actual_actions_for_controller(controller).include?('all')
        else
          expected_actions_for_controller == actual_actions_for_controller(controller)
        end
      end

      def all_actuel_actions
        @all_actuel_actions ||= begin
          @permission_service.instance_variable_get(@actions_instance_var) || {}
        end
      end

      def all_actuel_controllers
        @all_actuel_controllers ||= begin
          all_actuel_actions.keys.collect { |e| e.first }.uniq.sort
        end
      end

      def all_expected_controllers
        @all_expected_controllers ||= begin
          @all_expected_actions.collect { |e| e[0] }
        end.sort
      end

      def actual_actions_for_controller(controller)
        @actual_actions_for_controller ||= {}

        @actual_actions_for_controller[controller] ||= begin
          all_actuel_actions.keys.inject([]) do |actual_actions_for_controller, value|
            if value[0] == controller
              actual_actions_for_controller << value[1]
            end
            actual_actions_for_controller
          end.uniq.sort
        end
      end
    end
  end
end