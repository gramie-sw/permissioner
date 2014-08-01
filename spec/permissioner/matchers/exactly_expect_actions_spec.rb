require 'spec_helper'

describe Permissioner::Matchers::ExactlyExpectActions do

  let(:permission_service) do
    permission_service = PermissionService.new
    permission_service.allow_actions :comments, [:index, :show, :new, :create]
    permission_service.allow_actions :users, [:show, :new, :create]
    permission_service.allow_actions :posts, [:show, :edit, :update]
    permission_service
  end

  def create_matcher(*all_expected_actions)
    Permissioner::Matchers::ExactlyExpectActions.new(:@allowed_actions, *all_expected_actions)
  end

  describe '#initialize' do

    it 'should transform expected_actions into string array' do
      matcher = create_matcher [:controller, :action]
      expect(matcher.instance_variable_get(:@all_expected_actions)).to eq [['controller', ['action']]]
      matcher = create_matcher [:controller, [:action_1, :action_2]]
      expect(matcher.instance_variable_get(:@all_expected_actions)).to eq [['controller', ['action_1', 'action_2']]]
    end

    it 'should raise an exception if multiple actions not stated as array' do
      expect {
        create_matcher [:controller, :action_1, :action_2]
      }.to raise_exception "multiple actions for a controller must stated as array, e.g. [:new, :create]"
    end
  end

  describe '#matches' do

    context 'on success' do

      it 'should return true if all expected controllers with actions are exactly allowed' do
        matcher = create_matcher(
            [:comments, [:index, :show, :new, :create]],
            [:users, [:show, :new, :create]],
            [:posts, [:show, :edit, :update]]
        )
        expect(matcher.matches?(permission_service)).to be_truthy
      end

      it 'should return true if for a given controller all actions are allowed and all is expected' do
        permission_service.allow_actions :comments, :all
        matcher = create_matcher(
            [:comments, :all],
            [:users, [:show, :new, :create]],
            [:posts, [:show, :edit, :update]]
        )
        expect(matcher.matches?(permission_service)).to be_truthy
      end
    end

    context 'if controllers did not match' do

      it 'should return false if at least one expected controller is not allowed' do
        matcher = create_matcher(
            [:comments, [:index, :show, :new, :create]],
            [:users, [:show, :new, :create]],
            [:accounts, [:show, :edit, :update]]
        )
        expect(matcher.matches?(permission_service)).to be_falsey
      end

      it 'should return false if at least one controller is allowed but no expected' do
        matcher = create_matcher(
            [:comments, [:index, :show, :new, :create]],
            [:users, [:show, :new, :create]]
        )
        expect(matcher.matches?(permission_service)).to be_falsey
      end
    end

    context 'if actions for controllers did not match' do

      it 'should return false if at least one expected action is not allowed' do
        matcher = create_matcher(
            [:comments, [:update, :show, :new, :create]],
            [:users, [:show, :new, :create]],
            [:posts, [:show, :edit, :update]]
        )
        expect(matcher.matches?(permission_service)).to be_falsey
      end

      it 'should return false if at least one action is not allowed but no expected' do
        matcher = create_matcher(
            [:comments, [:index, :show, :new]],
            [:users, [:show, :new, :create]],
            [:posts, [:show, :edit, :update]]
        )
        expect(matcher.matches?(permission_service)).to be_falsey
      end
    end

    it 'should work even when not action is configured' do
      matcher = create_matcher(
          [:comments, [:update, :show, :new, :create]],
          [:users, [:show, :new, :create]],
          [:posts, [:show, :edit, :update]]
      )
      expect(matcher.matches?(PermissionService.new)).to be_falsey
    end
  end

  describe '#failure_message' do

    context 'if controllers did not match' do

      it 'should be available' do
        matcher = create_matcher(
            [:users, []],
            [:posts, []]
        )
        expected_messages =
            "expected to find actions for controllers \n" \
          "[\"posts\", \"users\"], but found actions for controllers\n"\
          "[\"comments\", \"posts\", \"users\"]"
        #call is necessary because matches sets @permission_service
        matcher.matches?(permission_service)
        expect(matcher.failure_message).to eq expected_messages
      end

      it 'should work if no controller allowed' do
        matcher = create_matcher(
            [:users, []],
            [:posts, []]
        )
        #call is necessary because matches sets @permission_service
        matcher.matches?(PermissionService.new)
        expect(matcher.failure_message).to be_kind_of(String)
      end
    end

    context 'if actions for controllers did not match' do

      it 'should be available' do
        matcher = create_matcher(
            [:comments, [:show, :new, :create]],
            [:users, [:show, :new, :create, :update]],
            [:posts, [:show, :edit, :update]]
        )
        expected_messages =
            "expected actions did not match for following controllers:\n"\
            "comments:\n"\
            "[\"create\", \"new\", \"show\"] were expected but found actions\n"\
            "[\"create\", \"index\", \"new\", \"show\"]\n"\
            "users:\n"\
            "[\"create\", \"new\", \"show\", \"update\"] were expected but found actions\n"\
            "[\"create\", \"new\", \"show\"]\n"
        #call is necessary because matches sets @permission_service
        matcher.matches?(permission_service)
        expect(matcher.failure_message).to eq expected_messages
      end


      it 'should work if no controller allowed' do
        matcher = create_matcher(
            [:comments, [:show, :new, :create]],
            [:users, [:show, :new, :create, :update]],
            [:posts, [:show, :edit, :update]]
        )
        #call is necessary because matches sets @permission_service
        matcher.matches?(PermissionService.new)
        expect(matcher.failure_message).to be_kind_of(String)
      end
    end
  end


  describe '# failure_message_when_negated' do

    it 'should be available' do
      matcher = create_matcher
      expected_messages = 'given actions are exactly match although this is not expected'
      expect(matcher. failure_message_when_negated).to eq expected_messages
    end

    it 'should be available' do
      matcher = create_matcher
      matcher.matches?(PermissionService.new)
      expect(matcher. failure_message_when_negated).to be_kind_of(String)
    end
  end

end