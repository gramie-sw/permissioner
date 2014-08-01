module Permissioner
  module Matchers
    class ExactlyAllowAttributes

      def initialize(*all_expected_attributes)
        @all_expected_attributes = all_expected_attributes.collect do |value|
          raise 'multiple attributes for a resource must stated as array, e.g. [:user_id, :username]' if value.size > 2
          [value[0], Array(value[1])]
        end
        @failing_attributes = []
      end

      def matches?(permission_service)
        @permission_service = permission_service
        expected_attributes_exactly_match?
      end

      def failure_message
        if @failing_attributes.empty?
          "expected to find allowed attributes for resources\n" \
          "#{all_expected_resources}, but found allowed attributes for resources\n"\
          "#{all_allowed_resources}"
        else
          message = "expected attributes did not match for following resources:\n"
          @failing_attributes.inject(message) do |msg, value|
            msg +=
                "#{value[0]}:\n"\
                "#{value[1]} were expected to be allowed, but attributes\n"\
                "#{allowed_attrributes_for_resource(value[0])} are allowed\n"
            msg
          end
        end
      end

      def failure_message_when_negated
        'given attributes are exactly allowed although this is not expected'
      end

      private

      def expected_attributes_exactly_match?
        resources_exactly_match? && attributes_exactly_match?
      end

      def resources_exactly_match?
        all_expected_resources == all_allowed_resources
      end

      def attributes_exactly_match?
        @all_expected_attributes.each do |resource, expected_attributes_for_resource|

          match = expected_attributes_for_resource.count == allowed_attrributes_for_resource(resource).count

          if match
            match = expected_attributes_for_resource.all? do |expected_attribute|
              @permission_service.allow_attribute?(resource, expected_attribute)
            end
          end

          unless match
            @failing_attributes << [resource, expected_attributes_for_resource]
          end
        end
        @failing_attributes.empty?
      end

      def all_expected_resources
        @all_expected_resources ||= begin
          @all_expected_attributes.collect { |value| value[0] }.sort
        end
      end

      def all_allowed_resources
        @all_allowed_resources ||= begin
          if all_allowed_attributes.any?
            all_allowed_attributes.keys.sort
          else
            []
          end
        end
      end

      def allowed_attrributes_for_resource(resource)
        @all_allowed_attributes ||= {}
        @all_allowed_attributes[resource] ||= begin
          if all_allowed_attributes[resource]
            all_allowed_attributes[resource].sort
          else
            []
          end
        end
      end

      def all_allowed_attributes
        @all_allowed_attributes ||= begin
          all_allowed_attributes = @permission_service.instance_variable_get(:@allowed_attributes)
          all_allowed_attributes || {}
        end
      end

      #def matches?(permission_service)
      #  @permission_service = permission_service
      #  expected_attributs_exactly_macht? allowed_attributes_for_resource
      #end
      #
      #def failure_message
      #  "expected that for resource \"#{@resource}\" attributes\n"\
      #  "#{@expected_attributes} are exactly allowed, but found attributes\n"\
      #  "#{allowed_attributes_for_resource} allowed"
      #end
      #
      #def  failure_message_when_negated
      #  "expected that for resource \"#{@resource}\" attributes\n"\
      #  "#{@expected_attributes} are exactly not allowed,\n"\
      #  "but those attributes are exactly allowed\n"
      #end
      #
      #private
      #
      #def expected_attributs_exactly_macht?(allowed_attributes_for_resource)
      #  allowed_attributes_for_resource.count == @expected_attributes.count &&
      #      @expected_attributes.all? { |attribute| allowed_attributes_for_resource.include? attribute }
      #end
      #
      #def allowed_attributes_for_resource
      #  @allowed_attributes_for_resource ||= begin
      #    all_allowed_attributes = @permission_service.instance_variable_get(:@allowed_attributes)
      #    if all_allowed_attributes && all_allowed_attributes[@resource]
      #      all_allowed_attributes[@resource]
      #    else
      #      []
      #    end
      #  end
      #end
    end
  end
end