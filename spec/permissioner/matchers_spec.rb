require 'spec_helper'

describe 'matchers' do

  before :each do
    @permission_service = double('permission_service')
  end

  describe 'allow_action' do

    it 'should delegate call to PermissionService#allow_action?' do
      @permission_service.should_receive(:allow_action?).with(:comments, :index).and_return(true)
      @permission_service.should allow_action :comments, :index
    end

    it 'should return false when PermissionService#allow_action? returns false' do
      @permission_service.should_receive(:allow_action?).and_return(false)
      @permission_service.should_not allow_action
    end
  end

  describe 'allow_attribute' do

    it 'should delegate call to PermissionService#allow_action?' do
      @permission_service.should_receive(:allow_attribute?).with(:comment, :user_id, :text).and_return(true)
      @permission_service.should allow_attribute :comment, :user_id, :text
    end

    it 'should return false when PermissionService#allow_action? returns false' do
      @permission_service.should_receive(:allow_attribute?).and_return(false)
      @permission_service.should_not allow_attribute
    end
  end

  describe 'pass_filters' do

    it 'should delegate call to PermissionService#passed_filters?' do
      @permission_service.should_receive(:passed_filters?).with(:comment, :user_id, :block).and_return(true)
      @permission_service.should pass_filters :comment, :user_id, :block
    end

    it 'should return false when PermissionService#passed_filters? returns false' do
      @permission_service.should_receive(:passed_filters?).and_return(false)
      @permission_service.should_not pass_filters
    end

    it 'should set empty Hash as default value for params argument' do
      @permission_service.should_receive(:passed_filters?).with(:comment, :user_id, {}).and_return(true)
      @permission_service.should pass_filters :comment, :user_id
    end
  end
end