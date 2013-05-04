require 'spec_helper'

describe Permissioner::PermissionConfigurer do

  before :each do
    @permission_configurer_class = Class.new
    @permission_configurer_class.send(:include, Permissioner::PermissionConfigurer)
    @permissioin_configurer = @permission_configurer_class.new
  end

  context 'delegation' do

    it 'should delegate call to allow_actions to permission_service' do
      @permissioin_configurer.should_receive(:allow_actions).with(:comments, :index)
      @permissioin_configurer.allow_actions(:comments, :index)
    end

    it 'should delegate call to allow_attributes to permission_service' do
      @permissioin_configurer.should_receive(:allow_attributes).with(:comment, [:user_id, :text])
      @permissioin_configurer.allow_attributes(:comment, [:user_id, :text])
    end

    it 'should delegate call to add_filter to permission_service' do
      @permissioin_configurer.should_receive(:add_filter).with(:comments, :create, Proc.new {})
      @permissioin_configurer.add_filter(:comments, :create, Proc.new {})
    end
  end

  describe '::included' do

    it 'should extend including class with module Permissioner::PermissionConfigurer::ClassMethods' do
      clazz = Class.new
      clazz.should_receive(:extend).with(Permissioner::PermissionConfigurer::ClassMethods)
      clazz.send(:include, Permissioner::PermissionConfigurer)
    end
  end
  
  describe '::create' do

    it 'should return permission_service instance' do
      permission_service = @permission_configurer_class.create(nil, nil)
      permission_service.class.included_modules.should include(Permissioner::PermissionConfigurer)
    end

    it 'should set permission_service' do
      @permission_configurer_class.any_instance.should_receive(:permission_service=).with('permission_service')
      @permission_configurer_class.create('permission_service', nil)
    end

    it 'should set current_user' do
      @permission_configurer_class.any_instance.should_receive(:current_user=).with('current_user')
      @permission_configurer_class.create(nil, 'current_user')
    end

    it 'should call configure_permissions current_user' do
      @permission_configurer_class.any_instance.should_receive(:configure_permissions)
      @permission_configurer_class.create(nil, nil)
    end
  end
end