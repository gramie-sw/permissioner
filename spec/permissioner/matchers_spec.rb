require 'spec_helper'

describe 'matchers' do

  let(:permission_service) { PermissionService.new }

  describe 'allow_action' do

    it 'should delegate call to PermissionService#allow_action? and pass when is returns true' do
      permission_service.should_receive(:allow_action?).with(:comments, :index).and_return(true)
      permission_service.should allow_action :comments, :index
    end

    it 'should fail when PermissionService#allow_action? returns false' do
      permission_service.should_receive(:allow_action?).and_return(false)
      permission_service.should_not allow_action
    end
  end

  describe 'allow_attribute' do

    it 'should delegate call to PermissionService#allow_action? and pass when is returns true' do
      permission_service.should_receive(:allow_attribute?).with(:comment, :user_id, :text).and_return(true)
      permission_service.should allow_attribute :comment, :user_id, :text
    end

    it 'should fail when PermissionService#allow_action? returns false' do
      permission_service.should_receive(:allow_attribute?).and_return(false)
      permission_service.should_not allow_attribute
    end
  end

  describe 'pass_filters' do

    it 'should delegate call to PermissionService#passed_filters? and pass when is returns true' do
      permission_service.should_receive(:passed_filters?).with(:comment, :user_id, :block).and_return(true)
      permission_service.should pass_filters :comment, :user_id, :block
    end

    it 'should fail when PermissionService#passed_filters? returns false' do
      permission_service.should_receive(:passed_filters?).and_return(false)
      permission_service.should_not pass_filters
    end

    it 'should set empty Hash as default value for params argument' do
      permission_service.should_receive(:passed_filters?).with(:comment, :user_id, {}).and_return(true)
      permission_service.should pass_filters :comment, :user_id
    end
  end

  describe 'exactly_allow_actions' do

    context 'actions are allowed' do

      before :each do
        permission_service.allow_actions :comments, [:index, :edit, :update]
      end

      it 'should pass if for given controller given actions are exactly allowed for given' do
        permission_service.should exactly_allow_actions :comments, [:index, :edit, :update]
      end

      it 'should pass if for given controller all actions are allowed and all is given' do
        permission_service.allow_actions :comments, :all
        permission_service.should exactly_allow_actions :comments, :all
      end

      it 'should also except arguments as string' do
        permission_service.should exactly_allow_actions 'comments', ['index', 'edit', 'update']
      end

      it 'should fail if for given controller not all given actions are allowed' do
        permission_service.should_not exactly_allow_actions :comments, [:index, :edit, :new]
      end

      it 'should fail if for given controller more than given actions are allowed' do
        permission_service.should_not exactly_allow_actions :comments, [:index, :edit]
      end

      it 'should except actions as single symbol when only one given' do
        permission_service.allow_actions :users, :index
        permission_service.should exactly_allow_actions :users, :index
      end

      it 'should have failure message for should' do
        matcher = exactly_allow_actions :users, [:index, :create]
        permission_service.should_not matcher
        expected_message =
            "expected that for \"UsersController\" exactly actions\n"\
        "[\"index\", \"create\"] are allowed, but found actions\n"\
        "[\"index\", \"edit\", \"update\"] as allowed"
        matcher.failure_message_for_should.should eq expected_message
      end
    end

    context 'no actions are allowed' do

      it 'should fail with no error by getting failure message' do
        matcher = exactly_allow_actions(:comments, :index)
        permission_service.should_not matcher
        matcher.failure_message_for_should
      end
    end
  end

  describe 'exactly_allow_attributes' do

    context 'attributes are allowed' do

      before :each do
        permission_service.allow_attributes :user, [:name, :email, :phone]
      end

      it 'should pass if for given resource exactly all given attributes are allowed' do
        permission_service.should exactly_allow_attributes :user, [:name, :email, :phone]
      end

      it 'should fail if for given resource not all given attributes are allowed' do
        permission_service.should_not exactly_allow_attributes :user, [:name, :email, :street]
      end

      it 'should fail if for given resource not all allowed attributes are given' do
        permission_service.should_not exactly_allow_attributes :user, [:name, :email]
      end
    end

    context 'no attributes are allowed' do

      it 'should pass if no resource is given' do
        permission_service.should exactly_allow_attributes
      end

      it 'should pass if only resource is given' do
        permission_service.should exactly_allow_attributes :comment
      end

      it 'should not pass if attributes are given' do
        permission_service.should_not exactly_allow_attributes :comment, :user_id
      end
    end
  end

end