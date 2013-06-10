require 'spec_helper'

describe Permissioner::ControllerAdditions do

  before :each do
    @controller_class = Class.new
    @controller_class.stub(:helper_method)
    @controller_class.send(:include, Permissioner::ControllerAdditions)
    @controller = @controller_class.new
    @controller.stub(:current_user)
  end

  describe '::included' do

    before :each do
      @clazz = Class.new
    end

    it 'should set view helpers' do
      @clazz.should_receive(:helper_method).with(:allow_action?, :allow_attribute?, :permission_service)
      @clazz.send(:include, Permissioner::ControllerAdditions)
    end

    it 'should delegate helper methods to permission servie' do
      @clazz.stub(:helper_method)
      @clazz.should_receive(:delegate).with(:allow_action?, :allow_attribute?, to: :permission_service)
      @clazz.send(:include, Permissioner::ControllerAdditions)
    end
  end


  describe 'authorize' do

    before :each do
      @params = {controller: 'comments', action: 'index'}
      @controller.stub(:params).and_return(@params)
    end

    it 'should call permit_params! if action allwed and filters passed' do
      @controller.permission_service.should_receive(:allow_action?).and_return(true)
      @controller.permission_service.should_receive(:passed_filters?).and_return(true)
      @controller.permission_service.should_receive(:permit_params!).with(@params)
      @controller.authorize
    end

    it 'should call allow_action? with correct parameters' do
      @controller.should_receive(:current_resource).and_return('current_resource')
      @controller.permission_service.should_receive(:allow_action?).with('comments', 'index', 'current_resource').and_return(true)
      @controller.permission_service.stub(:passed_filters?).and_return(true)
      @controller.authorize
    end

    it 'should call add_filters? with correct parameters' do
      @controller.should_receive(:current_resource).and_return('current_resource')
      @controller.permission_service.stub(:allow_action?).and_return(true)
      @controller.permission_service.should_receive(:passed_filters?).with('comments', 'index', @params).and_return(true)
      @controller.authorize
    end

    it 'should raise Permissioner::NotAuthorized when action not allowed' do
      @controller.permission_service.should_receive(:allow_action?).with('comments', 'index', nil).and_return(false)
      expect {
        @controller.authorize
      }.to raise_error Permissioner::NotAuthorized
    end

    it 'should raise Permissioner::NotAuthorized when action are allowed but filters did not passed' do
      @controller.permission_service.should_receive(:allow_action?).and_return(true)
      @controller.permission_service.should_receive(:passed_filters?).and_return(false)
      expect {
        @controller.authorize
      }.to raise_error Permissioner::NotAuthorized
    end
  end

  describe '#permission_service' do

    it 'should return instance of PermissionService' do
      @controller.permission_service.class.should eq PermissionService
    end

    it 'should cache PermissionService instance' do
      permission_service_1 = @controller.permission_service
      permission_service_2 = @controller.permission_service
      permission_service_1.should eq permission_service_2
    end

    it 'should create PermissionService by calling PermissionService::create' do
      PermissionService.should_receive(:create)
      @controller.permission_service
    end

    it 'should pass current_user to PermissionService::create' do
      @controller.should_receive(:current_user).and_return('current_user')
      PermissionService.should_receive(:create).with('current_user')
      @controller.permission_service
    end
  end

  describe '#current_resource' do

    it 'should return nil as default' do
      @controller.current_resource.should be_nil
    end
  end
end