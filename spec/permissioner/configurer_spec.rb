require 'spec_helper'

describe Permissioner::Configurer do

  let(:permission_configurer_class) do
    permission_configurer_class = Class.new
    permission_configurer_class.send(:include, Permissioner::Configurer)
    permission_configurer_class
  end

  context 'delegation' do
    let(:permission_service) { double('PermissionService') }
    let(:permission_configurer) { permission_configurer_class.new(permission_service, 'current_user') }

    it 'should delegate call to allow_actions to permission_service' do
      expect(permission_service).to receive(:allow_actions).with(:comments, :index)
      permission_configurer.allow_actions(:comments, :index)
    end

    it 'should delegate call to allow_attributes to permission_service' do
      expect(permission_service).to receive(:allow_attributes).with(:comment, [:user_id, :text])
      permission_configurer.allow_attributes(:comment, [:user_id, :text])
    end

    it 'should delegate call to add_filter to permission_service' do
      block = Proc.new {}
      expect(permission_service).to receive(:add_filter).with(:comments, :create, &block)
      permission_configurer.add_filter(:comments, :create, &block)
    end

    it 'should delegate call to clear_filter to permission_service' do
      block = Proc.new {}
      expect(permission_service).to receive(:clear_filters).with(no_args)
      permission_configurer.clear_filters
    end
  end

  context 'setters' do
    subject(:permission_configurer){ permission_configurer_class.new(nil, nil) }

    it 'should respond_to permission_service' do
      is_expected.to respond_to(:permission_service)
    end

    it 'should respond_to current_user' do
      is_expected.to respond_to(:current_user)
    end
  end

  describe '#initialize' do

    it 'should set permission_service' do
      permission_configurer = permission_configurer_class.new('permission_service', nil)
      expect(permission_configurer.permission_service).to eq 'permission_service'
    end

    it 'should set current_user' do
      permission_configurer = permission_configurer_class.new(nil, 'current_user')
      expect(permission_configurer.current_user).to eq 'current_user'
    end

    it 'should call configure_permissions current_user' do
      expect_any_instance_of(permission_configurer_class).to receive(:configure_permissions)
      permission_configurer_class.new(nil, nil)
    end
  end
end