require 'spec_helper'

describe Permissioner::Matchers::ExactlyAllowActions do

  let(:permission_service) do
    permission_service = PermissionService.new
    permission_service.allow_actions :comments, [:index, :edit, :update]
    permission_service.allow_actions :users, [:show, :new, :create]
    permission_service
  end

  def create_matcher(controller, expected_actions)
    Permissioner::Matchers::ExactlyAllowActions.new(controller, expected_actions)
  end

  describe '#initialize' do

    it 'should transform controller to string' do
      matcher = create_matcher(:comments, nil)
      matcher.instance_variable_get(:@controller).should eq 'comments'
    end

    it 'should transform expected_actions in to string array' do
      matcher = create_matcher nil, :index
      matcher.instance_variable_get(:@expected_actions).should eq ['index']
      matcher = create_matcher nil, [:index, :edit]
      matcher.instance_variable_get(:@expected_actions).should eq ['index', 'edit']
    end
  end

  describe '#matches' do

    it 'should return true if for given controller given actions are exactly allowed for given' do
      matcher = create_matcher :comments, [:index, :edit, :update]
      matcher.matches?(permission_service).should be_true
    end

    it 'should return true if for given controller all actions are allowed and all is given' do
      permission_service.allow_actions :comments, :all
      matcher = create_matcher :comments, :all
      matcher.matches?(permission_service).should be_true
    end

    it 'should return false if for given controller not all given actions are allowed' do
      matcher = create_matcher :comments, [:index, :edit, :new]
      matcher.matches?(permission_service).should be_false
    end

    it 'should return fasle if for given controller more than given actions are allowed' do
      matcher = create_matcher :comments, [:index, :edit]
      matcher.matches?(permission_service).should be_false
    end
  end

  describe '#failure_message_for_should' do

    it 'should be available' do
      matcher = create_matcher :users, [:index, :new]
      expected_messages =
          "expected that for \"UsersController\" actions\n"\
          "[\"index\", \"new\"] are exactly allowed, but found actions\n"\
          "[\"create\", \"new\", \"show\"] allowed"
      #call is necessary because matches sets @permission_service
      matcher.matches?(permission_service)
      matcher.failure_message_for_should.should eq expected_messages
    end

    it 'should correctly camalize controller name' do
      matcher = create_matcher :app_user, :index
      #call is necessary because matches sets @permission_service
      matcher.matches?(permission_service)
      matcher.failure_message_for_should.should match('AppUserController')
    end

    it 'should work if no controller allowed' do
      matcher = create_matcher :users, [:index, :new]
      #call is necessary because matches sets @permission_service
      matcher.matches?(PermissionService.new)
      matcher.failure_message_for_should.should be_kind_of(String)
    end
  end

  describe '#failure_message_for_should_not' do

    it 'should be available' do
      matcher = create_matcher :users, [:index, :new, :create]
      expected_messages =
          "expected to exactly not allow actions"\
          "[\"create\", \"index\", \"new\"] for UsersControllers \n"\
          "#but these actions are exactly allowed\n"
      matcher.failure_message_for_should_not.should eq expected_messages
    end

    it 'should correctly camalize controller name' do
      matcher = create_matcher :app_user, :index
      matcher.failure_message_for_should_not.should match('AppUserController')
    end

    it 'should work if no controller allowed' do
      matcher = create_matcher :users, [:index, :new]
      matcher.failure_message_for_should_not.should be_kind_of(String)
    end
  end

end