require 'spec_helper'

describe Permissioner::ControllerAdditions do

  let(:controller) do
    controller_class = Class.new
    allow(controller_class).to receive(:helper_method)
    controller_class.send(:include, Permissioner::ControllerAdditions)
    controller = controller_class.new
    allow(controller).to receive(:current_user)
    controller
  end

  describe '::included' do

    let(:clazz) { Class.new }

    it 'should set view helpers' do
      expect(clazz).to receive(:helper_method).with(:allow_action?, :allow_attribute?, :permission_service)
      clazz.send(:include, Permissioner::ControllerAdditions)
    end

    it 'should delegate helper methods to permission servie' do
      allow(clazz).to receive(:helper_method)
      expect(clazz).to receive(:delegate).with(:allow_action?, :allow_attribute?, to: :permission_service)
      clazz.send(:include, Permissioner::ControllerAdditions)
    end
  end

  describe 'authorize' do

    let(:params) { {controller: 'comments', action: 'index'} }

    before :each do
      allow(controller).to receive(:current_resource).and_return('resource')
      allow(controller).to receive(:params).and_return(params)
    end

    it 'should call permit_params! if action allwed and filters passed' do
      expect(controller.permission_service).to receive(:allow_action?).and_return(true)
      expect(controller.permission_service).to receive(:permit_params!).with(params)
      controller.authorize
    end

    it 'should call allow_action? with correct parameters' do
      expect(controller.permission_service).to receive(:allow_action?).with('comments', 'index', resource: 'resource', params: params).and_return(true)
      controller.authorize
    end

    it 'should raise Permissioner::NotAuthorized when action not allowed' do
      expect(controller.permission_service).to receive(:allow_action?).with('comments', 'index', resource: 'resource', params: params).and_return(false)
      expect {
        controller.authorize
      }.to raise_error Permissioner::NotAuthorized
    end
  end

  describe '#permission_service' do

    it 'should return instance of PermissionService' do
      expect(controller.permission_service.class).to eq PermissionService
    end

    it 'should cache PermissionService instance' do
      expect(controller.permission_service).to be controller.permission_service
    end

    it 'should create PermissionService by calling PermissionService::new' do
      expect(PermissionService).to receive(:new)
      controller.permission_service
    end

    it 'should pass current_user to PermissionService::initialize' do
      expect(controller).to receive(:current_user).and_return('current_user')
      expect(PermissionService).to receive(:new).with('current_user')
      controller.permission_service
    end
  end

  describe '#current_resource' do

    it 'should return nil as default' do
      expect(controller.current_resource).to be_nil
    end
  end
end