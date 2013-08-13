module Permissioner
  module Matchers
    class ExactlyAllowActions

      def initialize(controller, expected_actions)
        @controller = controller.to_s
        @expected_actions = Array(expected_actions).collect { |action| action.to_s }
      end

      def matches?(permission_service)
        @permission_service = permission_service
        expected_actions_exactly_match? all_allowed_actions(permission_service)
      end

      def failure_message_for_should
        "expected that for \"#{to_camelcase @controller}Controller\" actions\n" \
        "#{@expected_actions.sort} are exactly allowed, but found actions\n"\
        "#{allowed_actions_for_controller(all_allowed_actions(@permission_service)).sort} allowed"
      end

      def failure_message_for_should_not
        "expected to exactly not allow actions"\
        "#{@expected_actions.sort} for #{to_camelcase @controller}Controllers \n"\
        "#but these actions are exactly allowed\n"\

      end

      private

      def expected_actions_exactly_match?(all_allowed_actions)
        if @expected_actions == ['all']
          all_allowed_actions.include?([@controller, 'all'])
        else
          allowed_actions_for_controller(all_allowed_actions).count == @expected_actions.count &&
              all_expected_actions_allowed?(all_allowed_actions)
        end
      end

      def all_allowed_actions(permission_service)
        @all_allowed_actions ||= begin
          permission_service.instance_variable_get(:@allowed_actions) || {}
        end
      end

      def allowed_actions_for_controller(all_allowed_actions)
        @allowed_actions_for_controller ||= begin
          all_allowed_actions.keys.inject([]) do |allowed_actions, e|
            if e[0] == @controller
              allowed_actions << e[1]
            end
            allowed_actions
          end.uniq
        end
      end

      def all_expected_actions_allowed?(all_allowed_actions)
        @expected_actions.all? { |action| all_allowed_actions[[@controller, action]] }
      end

      def to_camelcase(string)
        return string if string !~ /_/ && self =~ /[A-Z]+.*/
        string.split('_').map{|e| e.capitalize}.join
      end

    end
  end
end