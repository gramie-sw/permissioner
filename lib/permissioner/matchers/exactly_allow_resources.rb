module Permissioner
  module Matchers
    class ExactlyAllowResources

      def initialize(*expected_resources)
        @expected_resources = expected_resources
      end

      def matches?(permission_service)
        @permission_service = permission_service
        resources_exactly_match?
      end

      def failure_message
        "expected to exactly allow resources \n" \
        "#{@expected_resources.sort}, but found resources\n"\
        "#{allowed_resources.sort} allowed"
      end

      def  failure_message_when_negated
        "expected to exactly not allow resources \n" \
        "#{@expected_resources.sort}, but these resources are exactly allowed\n"\
      end

      private

      def resources_exactly_match?
        allowed_resources.count == @expected_resources.count &&
            @expected_resources.all? { |resource| allowed_resources.include? resource }
      end

      def allowed_resources
        @allowed_resources ||= begin
          allowed_attributes = @permission_service.instance_variable_get(:@allowed_attributes)
          if allowed_attributes
            allowed_attributes.keys
          else
            []
          end
        end
      end
    end
  end
end