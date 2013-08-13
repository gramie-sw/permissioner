module Permissioner
  module Matchers
    class ExactlyAllowActions

      def initialize(*all_expected_actions)
        all_expected_actions.collect! do |e|
          raise 'multiple actions for a controller must stated in an array, e.g. [:new, :create]' if e.size > 2
          [e[0].to_s, Array(e[1]).collect! { |e| e.to_s }]
        end
        @all_expected_actions = all_expected_actions
        @failing_actions = []
      end

      def matches?(permission_service)
        @permission_service = permission_service
        expected_actions_exactly_match?
      end

      def failure_message_for_should
        if @failing_actions.empty?
          "expected to find allowed actions for controllers \n" \
          "#{all_expected_controllers}, but found allowed actions for controllers\n"\
          "#{all_allowed_controllers}"
        else
          message = "expected allowed actions did not match for following controllers:\n"
          @failing_actions.inject(message) do |msg, value|
            msg +=
                "#{value[0]}:\n"\
                "#{value[1]} were expected to be allowed, but actions\n"\
                "#{allowed_actions_for_controller(value[0])} are allowed\n"
            msg
          end
        end
      end

      def failure_message_for_should_not
        "given actions are exactly allowed although this is not expected"
      end

      private

      def expected_actions_exactly_match?
        controllers_exactly_match? && actions_exactly_match?
      end

      def controllers_exactly_match?
        all_allowed_controllers == all_expected_controllers
      end

      def actions_exactly_match?
        @all_expected_actions.collect do |controller, expected_actions_for_controller|
          expected_actions_for_controller.sort!
          match = actions_for_controller_exactly_match?(controller, expected_actions_for_controller)
          @failing_actions << [controller, expected_actions_for_controller] unless match
          match
        end
        @failing_actions.empty?
      end

      def actions_for_controller_exactly_match?(controller, expected_actions_for_controller)
        if expected_actions_for_controller == ['all']
          allowed_actions_for_controller(controller).include?('all')
        else
          expected_actions_for_controller == allowed_actions_for_controller(controller)
        end
      end

      def all_allowed_actions
        @all_allowed_actions ||= begin
          @permission_service.instance_variable_get(:@allowed_actions) || {}
        end
      end

      def all_allowed_controllers
        @all_allowed_controllers ||= begin
          all_allowed_actions = @permission_service.instance_variable_get(:@allowed_actions)
          if all_allowed_actions
            all_allowed_actions.keys.collect { |e| e.first }.uniq
          else
            []
          end
        end.sort
      end

      def all_expected_controllers
        @all_expected_controllers ||= begin
          @all_expected_actions.collect { |e| e[0] }
        end.sort
      end

      def allowed_actions_for_controller(controller)
        @all_allowed_actions_for_controller ||= {}

        @all_allowed_actions_for_controller[controller] ||= begin
          all_allowed_actions.keys.inject([]) do |allowed_actions_for_controller, e|
            if e[0] == controller
              allowed_actions_for_controller << e[1]
            end
            allowed_actions_for_controller
          end.uniq.sort
        end
      end
    end
  end
end