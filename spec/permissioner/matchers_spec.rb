require 'spec_helper'

describe Permissioner::Matchers do

  let(:matcher_helper) do
    matcher_helper = Class.new
    matcher_helper.extend(Permissioner::Matchers)
    matcher_helper
  end

  let(:permission_service) { PermissionService.new }

  describe '#allow_action' do

    it 'should delegate call to PermissionService#allow_action? and pass when is returns true' do
      permission_service.should_receive(:allow_action?).with(:comments, :index).and_return(true)
      permission_service.should allow_action :comments, :index
    end

    it 'should fail when PermissionService#allow_action? returns false' do
      permission_service.should_receive(:allow_action?).and_return(false)
      permission_service.should_not allow_action
    end
  end

  describe '#allow_attribute' do

    it 'should delegate call to PermissionService#allow_action? and pass when is returns true' do
      permission_service.should_receive(:allow_attribute?).with(:comment, :user_id, :text).and_return(true)
      permission_service.should allow_attribute :comment, :user_id, :text
    end

    it 'should fail when PermissionService#allow_action? returns false' do
      permission_service.should_receive(:allow_attribute?).and_return(false)
      permission_service.should_not allow_attribute
    end
  end

  describe '#pass_filters' do

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

  describe '#exactly_allow_actions' do

    it 'should return correctly instantiated instance of ExactlyAllowActions' do
      expected_actions = [:controller_1, :actions_1], [:controller_2, :actions_2]
      Permissioner::Matchers::ExactlyAllowActions.should_receive(:new).with(*expected_actions).and_call_original
      matcher_helper.exactly_allow_actions(*expected_actions).should be_kind_of(Permissioner::Matchers::ExactlyAllowActions)
    end
  end

  describe '#exactly_allow_attributes' do

    it 'should return correctly instantiated instance of ExactlyAllowAttributes' do
      Permissioner::Matchers::ExactlyAllowAttributes.should_receive(:new).with(:resource, :attributes).and_call_original
      matcher_helper.exactly_allow_attributes(:resource, :attributes).should be_kind_of(Permissioner::Matchers::ExactlyAllowAttributes)
    end
  end

  describe '#exactly_allow_controllers' do

    it 'should return correctly instantiated instance of ExactlyAllowControllers' do
      Permissioner::Matchers::ExactlyAllowControllers.should_receive(:new).with(:controller_1, :controller_2).and_call_original
      matcher_helper.exactly_allow_controllers(:controller_1, :controller_2).should be_kind_of(Permissioner::Matchers::ExactlyAllowControllers)
    end
  end

  describe '#exactly_allow_resources' do

    it 'should return correctly instantiated instance of ExactlyAllowControllers' do
      Permissioner::Matchers::ExactlyAllowResources.should_receive(:new).with(:resource_1, :resource_2).and_call_original
      matcher_helper.exactly_allow_resources(:resource_1, :resource_2).should be_kind_of(Permissioner::Matchers::ExactlyAllowResources)
    end
  end

end