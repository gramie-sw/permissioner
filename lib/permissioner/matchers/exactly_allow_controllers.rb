module Permissioner
  module Matchers
    class ExactlyAllowControllers

      def initialize(*expected_controllers)
        @expected_controllers = expected_controllers.collect { |controller| controller.to_s }
      end

      def matches?(permission_service)
        @permission_service = permission_service
        controllers_exactly_match?(allowed_controllers)
      end

      def failure_message
        "expected to exactly allow controllers \n" \
          "#{@expected_controllers.sort}, but found controllers\n"\
          "#{allowed_controllers.sort} allowed"
      end

      def  failure_message_when_negated
        "expected to exactly not allow controllers \n" \
          "#{@expected_controllers.sort}, but these controllers are exactly allowed\n"\
      end

      private

      def allowed_controllers
        @allowed_controllers ||= begin
          all_allowed_actions = @permission_service.instance_variable_get(:@allowed_actions)
          if all_allowed_actions
            all_allowed_actions.keys.collect { |e| e.first }.uniq
          else
            []
          end
        end
      end

      def all_controllers_allowed?(allowed_controllers)
        @expected_controllers.all? { |controller| allowed_controllers.include? controller }
      end

      def controllers_exactly_match?(allowed_controllers)
        allowed_controllers.count == @expected_controllers.count && all_controllers_allowed?(allowed_controllers)
      end

    end
  end
end