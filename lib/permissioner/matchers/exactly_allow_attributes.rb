module Permissioner
  module Matchers
    class ExactlyAllowAttributes

      def initialize(resource, expected_attributes)
        @resource = resource
        @expected_attributes = Array(expected_attributes)
      end

      def matches?(permission_service)
        @permission_service = permission_service
        expected_attributs_exactly_macht? allowed_attributes_for_resource
      end

      def failure_message_for_should
        "expected that for resource \"#{@resource}\" attributes\n"\
        "#{@expected_attributes} are exactly allowed, but found attributes\n"\
        "#{allowed_attributes_for_resource} allowed"
      end

      def failure_message_for_should_not
        "expected that for resource \"#{@resource}\" attributes\n"\
        "#{@expected_attributes} are exactly not allowed,\n"\
        "but those attributes are exactly allowed\n"
      end

      private

      def expected_attributs_exactly_macht?(allowed_attributes_for_resource)
        allowed_attributes_for_resource.count == @expected_attributes.count &&
            @expected_attributes.all? { |attribute| allowed_attributes_for_resource.include? attribute }
      end

      def allowed_attributes_for_resource
        @allowed_attributes_for_resource ||= begin
          all_allowed_attributes = @permission_service.instance_variable_get(:@allowed_attributes)
          if all_allowed_attributes && all_allowed_attributes[@resource]
            all_allowed_attributes[@resource]
          else
            []
          end
        end
      end

    end
  end
end