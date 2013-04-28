require 'spec_helper'

describe 'Permissioner::PermissionServiceAdditions' do

  before :each do
    permission_service_class = Class.new
    permission_service_class.send(:include, Permissioner::PermissionServiceAdditions)
    @permission_service = permission_service_class.new
  end

  describe '#allow_action?' do

    it 'should return true if @allow_all is true' do
      @permission_service.allow_all
      @permission_service.allow_action?(:comments, :index).should be_true
    end

    context 'when no block given' do

      it 'should return true if given action allowed' do
        @permission_service.allow_actions :comments, :index
        @permission_service.allow_action?(:comments, :index).should be_true
      end

      it 'should return false if given action not allowed' do
        @permission_service.allow_action?(:comments, :index).should be_false
        @permission_service.allow_actions :comments, :create
        @permission_service.allow_action?(:comments, :index).should be_false
      end
    end

    context 'when block given' do

      it 'should call block for given action when ressource is given' do
        block = Proc.new {}
        block.should_receive(:call)
        @permission_service.allow_actions :comments, :index, &block
        @permission_service.allow_action?(:comments, :index, 'resource')
      end

      it 'should not call block for given action but no ressource is given' do
        block = Proc.new {}
        block.should_receive(:call).never
        @permission_service.allow_actions :comments, :index, &block
        @permission_service.allow_action?(:comments, :index)
      end

      it 'should return true when block returns true' do
        block = Proc.new { true }
        @permission_service.allow_actions :comments, :index, &block
        @permission_service.allow_action?(:comments, :index, 'resource').should be_true
      end

      it 'should return false when block returns false' do
        block = Proc.new { false }
        @permission_service.allow_actions :comments, :index, &block
        @permission_service.allow_action?(:comments, :index, 'resource').should be_false
      end

      it 'should return false when no ressource given' do
        block = Proc.new { true }
        @permission_service.allow_actions :comments, :index, &block
        @permission_service.allow_action?(:comments, :index).should be_false
      end
    end
  end

  describe '#allow_params?' do

    it 'should return true when @allow_all is true' do
      @permission_service.allow_all
      @permission_service.allow_param?(:comment, :user_id).should be_true
    end

    it 'should return true when param is allowed' do
      @permission_service.allow_params(:comment, :user_id)
      @permission_service.allow_param?(:comment, :user_id).should be_true
    end

    it 'should return false when param not allowed' do
      @permission_service.allow_param?(:comment, :user_id).should be_false
    end
  end

  describe '#permit_params!' do

    it 'call permit! on given params when @allow_all is true' do
      params = double('params')
      params.should_receive(:permit!)
      @permission_service.allow_all
      @permission_service.permit_params!(params)
    end
  end

  describe '#allow_all' do

    it 'should set @allow_all to true' do
      @permission_service.allow_all
      @permission_service.instance_variable_get(:@allow_all).should be_true
    end
  end

  describe '#allow_actions' do

    it 'should add controller and action to @allowed_actions' do
      @permission_service.allow_actions :comments, :index
      allowed_actions = @permission_service.instance_variable_get(:@allowed_actions)
      allowed_actions.count.should eq 1
      allowed_actions[['comments', 'index']].should be_true
    end

    it 'should add controllers and action to @allowed_actions when multiple given' do
      @permission_service.allow_actions([:comments, :users], [:index, :create])
      allowed_actions = @permission_service.instance_variable_get(:@allowed_actions)
      allowed_actions.count.should eq 4
      allowed_actions[['comments', 'index']].should be_true
      allowed_actions[['comments', 'create']].should be_true
      allowed_actions[['users', 'index']].should be_true
      allowed_actions[['users', 'create']].should be_true
    end

    it 'should add controllers and action to @allowed_actions and store block when given' do
      block = Proc.new {}
      @permission_service.allow_actions(:comments, :edit, &block)
      allowed_actions = @permission_service.instance_variable_get(:@allowed_actions)
      allowed_actions[['comments', 'edit']].object_id.should eq block.object_id
    end
  end

  describe '#allow_params' do

    it 'should add resource and attribute to @allowed_params' do
      @permission_service.allow_params :comment, :text
      allowed_params = @permission_service.instance_variable_get(:@allowed_params)
      allowed_params.count.should eq 1
      allowed_params[:comment].should eq [:text]
    end

    it 'should add resource and attribute to @allowed_params if multiple given' do
      @permission_service.allow_params [:comment, :post], [:user, :text]
      allowed_params = @permission_service.instance_variable_get(:@allowed_params)
      allowed_params.count.should eq 2
      allowed_params[:comment].should eq [:user, :text]
      allowed_params[:post].should eq [:user, :text]
    end
  end
end