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
      expect(permission_service).to receive(:allow_action?).with(:comments, :index, resource: 'resource', params: 'params').and_return(true)
      expect(permission_service).to allow_action :comments, :index, resource: 'resource', params: 'params'
    end

    it 'should fail when PermissionService#allow_action? returns false' do
      expect(permission_service).to receive(:allow_action?).and_return(false)
      expect(permission_service).not_to allow_action
    end
  end

  describe '#allow_attribute' do

    it 'should delegate call to PermissionService#allow_action? and pass when is returns true' do
      expect(permission_service).to receive(:allow_attribute?).with(:comment, :user_id, :text).and_return(true)
      expect(permission_service).to allow_attribute :comment, :user_id, :text
    end

    it 'should fail when PermissionService#allow_action? returns false' do
      expect(permission_service).to receive(:allow_attribute?).and_return(false)
      expect(permission_service).not_to allow_attribute
    end
  end

  describe '#pass_filters' do

    it 'should delegate call to PermissionService#passed_filters? and pass when is returns true' do
      expect(permission_service).to receive(:passed_filters?).with(:comment, :user_id, resource: 'resource', params: 'params').and_return(true)
      expect(permission_service).to pass_filters :comment, :user_id, resource: 'resource', params: 'params'
    end

    it 'should fail when PermissionService#passed_filters? returns false' do
      expect(permission_service).to receive(:passed_filters?).and_return(false)
      expect(permission_service).not_to pass_filters
    end
  end

  describe '#exactly_allow_actions' do

    it 'should return correctly instantiated instance of ExactlyExpectActions' do
      expected_actions = [:controller_1, :actions_1], [:controller_2, :actions_2]
      expect(Permissioner::Matchers::ExactlyExpectActions).to receive(:new).with(:@allowed_actions, *expected_actions).and_call_original
      expect(matcher_helper.exactly_allow_actions(*expected_actions)).to be_kind_of(Permissioner::Matchers::ExactlyExpectActions)
    end
  end

  describe '#exactly_have_filters_for' do

    it 'should return correctly instantiated instance of ExactlyExpectActions' do
      expected_actions = [:controller_1, :actions_1], [:controller_2, :actions_2]
      expect(Permissioner::Matchers::ExactlyExpectActions).to receive(:new).with(:@filters, *expected_actions).and_call_original
      expect(matcher_helper.exactly_have_filters_for(*expected_actions)).to be_kind_of(Permissioner::Matchers::ExactlyExpectActions)
    end
  end

  describe '#exactly_allow_attributes' do

    it 'should return correctly instantiated instance of ExactlyAllowAttributes' do
      expected_attributes = [:resource_1, :attribute_1], [:resource_2, :attribute_2]
      expect(Permissioner::Matchers::ExactlyAllowAttributes).to receive(:new).with(*expected_attributes).and_call_original
      expect(matcher_helper.exactly_allow_attributes(*expected_attributes)).to be_kind_of(Permissioner::Matchers::ExactlyAllowAttributes)
    end
  end

  describe '#exactly_allow_controllers' do

    it 'should return correctly instantiated instance of ExactlyAllowControllers' do
      expect(Permissioner::Matchers::ExactlyAllowControllers).to receive(:new).with(:controller_1, :controller_2).and_call_original
      expect(matcher_helper.exactly_allow_controllers(:controller_1, :controller_2)).to be_kind_of(Permissioner::Matchers::ExactlyAllowControllers)
    end
  end

  describe '#exactly_allow_resources' do

    it 'should return correctly instantiated instance of ExactlyAllowControllers' do
      expect(Permissioner::Matchers::ExactlyAllowResources).to receive(:new).with(:resource_1, :resource_2).and_call_original
      expect(matcher_helper.exactly_allow_resources(:resource_1, :resource_2)).to be_kind_of(Permissioner::Matchers::ExactlyAllowResources)
    end
  end

end