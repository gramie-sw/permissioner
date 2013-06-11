require 'spec_helper'

describe Permissioner::PermissionServiceAdditions do

  let(:permission_service_class) do
    permission_service_class = Class.new
    permission_service_class.send(:include, Permissioner::PermissionServiceAdditions)
    permission_service_class
  end

  let(:permission_service) { permission_service_class.new }

  describe '#initialize' do

    it 'should call configure_permissions' do
      permission_service_class.any_instance.should_receive(:configure_permissions).once
      permission_service_class.new
    end

    it 'should set current_user' do
      permission_service = permission_service_class.new 'current_user'
      permission_service.current_user.should eq 'current_user'
    end
  end

  describe '#allow_action?' do

    it 'should return true if @allow_all is true' do
      permission_service.allow_all
      permission_service.allow_action?(:comments, :index).should be_true
    end

    context 'when no block given' do

      it 'should return true if given action allowed' do
        permission_service.allow_actions :comments, :index
        permission_service.allow_action?(:comments, :index).should be_true
      end

      it 'should return false if given action not allowed' do
        permission_service.allow_action?(:comments, :index).should be_false
        permission_service.allow_actions :comments, :create
        permission_service.allow_action?(:comments, :index).should be_false
      end
    end

    context 'when block given' do

      it 'should call block for given action when ressource is given' do
        block = Proc.new {}
        block.should_receive(:call)
        permission_service.allow_actions :comments, :index, &block
        permission_service.allow_action?(:comments, :index, 'resource')
      end

      it 'should not call block for given action but no ressource is given' do
        block = Proc.new {}
        block.should_receive(:call).never
        permission_service.allow_actions :comments, :index, &block
        permission_service.allow_action?(:comments, :index)
      end

      it 'should return true when block returns true' do
        block = Proc.new { true }
        permission_service.allow_actions :comments, :index, &block
        permission_service.allow_action?(:comments, :index, 'resource').should be_true
      end

      it 'should return false when block returns false' do
        block = Proc.new { false }
        permission_service.allow_actions :comments, :index, &block
        permission_service.allow_action?(:comments, :index, 'resource').should be_false
      end

      it 'should return false when no ressource given' do
        block = Proc.new { true }
        permission_service.allow_actions :comments, :index, &block
        permission_service.allow_action?(:comments, :index).should be_false
      end
    end
  end

  describe '#passed_filters?' do

    it 'should return true when all blocks for given controller and action returns true' do
      permission_service.add_filter(:comments, :create, &Proc.new { true })
      permission_service.passed_filters?(:comments, :create, 'params').should be_true
    end

    it 'should return true when no filters are added at all' do
      permission_service.passed_filters?(:comments, :create, 'params').should be_true
    end

    it 'should return true when for given controller and action no filters has been added' do
      permission_service.add_filter(:comments, :update, &Proc.new {})
      permission_service.passed_filters?(:comments, :create, 'params').should be_true
    end

    it 'should return false when at least one block for given controller and action returns false' do
      permission_service.add_filter(:comments, :create, &Proc.new { true })
      permission_service.add_filter(:comments, :create, &Proc.new { false })
      permission_service.add_filter(:comments, :create, &Proc.new { true })
      permission_service.passed_filters?(:comments, :create, 'params').should be_false
    end

    it 'should pass params to the given block' do
      params = Object.new
      permission_service.add_filter(:comments, :create, &Proc.new { |p| p.object_id.should eq params.object_id })
      permission_service.passed_filters?(:comments, :create, params)
    end
  end

  describe '#allow_attributes?' do

    it 'should return true when @allow_all is true' do
      permission_service.allow_all
      permission_service.allow_attribute?(:comment, :user_id).should be_true
    end

    it 'should return true when param is allowed' do
      permission_service.allow_attributes(:comment, :user_id)
      permission_service.allow_attribute?(:comment, :user_id).should be_true
    end

    it 'should return false when param not allowed' do
      permission_service.allow_attribute?(:comment, :user_id).should be_false
    end
  end

  describe '#permit_params!' do

    it 'should call permit! on given params when @allow_all is true' do
      params = double('params')
      params.should_receive(:permit!)
      permission_service.allow_all
      permission_service.permit_params!(params)
    end

    it 'should call permit on allowed params' do
      params = {comment: {user_id: '12', text: 'text', date: 'date'}, post: {title: 'title', content: 'content'}}
      permission_service.allow_attributes(:comment, [:user_id, :text])
      permission_service.allow_attributes(:post, [:title, :content])
      params[:comment].should_receive(:respond_to?).with(:permit).and_return(true)
      params[:comment].should_receive(:permit).with(:user_id, :text)
      params[:post].should_receive(:permit).with(:title, :content)
      permission_service.permit_params!(params)
    end
  end

  describe '#allow_all' do

    it 'should set @allow_all to true' do
      permission_service.allow_all
      permission_service.instance_variable_get(:@allow_all).should be_true
    end
  end

  describe '#allow_actions' do

    it 'should add controller and action to @allowed_actions' do
      permission_service.allow_actions :comments, :index
      allowed_actions = permission_service.instance_variable_get(:@allowed_actions)
      allowed_actions.count.should eq 1
      allowed_actions[['comments', 'index']].should be_true
    end

    it 'should add controllers and action to @allowed_actions when multiple given' do
      permission_service.allow_actions([:comments, :users], [:index, :create])
      allowed_actions = permission_service.instance_variable_get(:@allowed_actions)
      allowed_actions.count.should eq 4
      allowed_actions[['comments', 'index']].should be_true
      allowed_actions[['comments', 'create']].should be_true
      allowed_actions[['users', 'index']].should be_true
      allowed_actions[['users', 'create']].should be_true
    end

    it 'should add controllers and action to @allowed_actions and store block when given' do
      block = Proc.new {}
      permission_service.allow_actions(:comments, :edit, &block)
      allowed_actions = permission_service.instance_variable_get(:@allowed_actions)
      allowed_actions[['comments', 'edit']].object_id.should eq block.object_id
    end
  end

  describe '#allow_attributes' do

    it 'should add resource and attribute to @allowed_params' do
      permission_service.allow_attributes :comment, :text
      allowed_params = permission_service.instance_variable_get(:@allowed_attributes)
      allowed_params.count.should eq 1
      allowed_params[:comment].should eq [:text]
    end

    it 'should add resource and attribute to @allowed_params if multiple given' do
      permission_service.allow_attributes [:comment, :post], [:user, :text]
      allowed_params = permission_service.instance_variable_get(:@allowed_attributes)
      allowed_params.count.should eq 2
      allowed_params[:comment].should eq [:user, :text]
      allowed_params[:post].should eq [:user, :text]
    end
  end

  describe '#add_filter' do

    it 'should add given block to @filters addressed by controller and action' do
      block = Proc.new {}
      permission_service.add_filter(:comments, :create, &block)
      filter_list = permission_service.instance_variable_get(:@filters)[['comments', 'create']]
      filter_list.count.should eq 1
      filter_list.should include block
    end

    it 'should add given block to @filters addressed by controller and action when multiple given' do
      block = Proc.new {}
      permission_service.add_filter([:comments, :posts], [:create, :update], &block)
      permission_service.instance_variable_get(:@filters)[['comments', 'create']].should include block
      permission_service.instance_variable_get(:@filters)[['comments', 'update']].should include block
      permission_service.instance_variable_get(:@filters)[['posts', 'create']].should include block
      permission_service.instance_variable_get(:@filters)[['posts', 'update']].should include block
    end

    it 'should add multiple blocks to @filters addressed by controller and action' do
      block_1 = Proc.new { 'block 1' }
      block_2 = Proc.new { 'block 2' }
      permission_service.add_filter(:comments, :create, &block_1)
      permission_service.add_filter(:comments, :create, &block_2)
      filter_list = permission_service.instance_variable_get(:@filters)[['comments', 'create']]
      filter_list.count.should eq 2
      filter_list.should include block_1
      filter_list.should include block_2
    end

    it 'should rails exception when no block given' do
      expect { permission_service.add_filter(:comments, :index) }.to raise_error('no block given')
    end
  end

  describe 'configure' do

    it 'should call create on the given configurer class' do
      permission_service.stub(:current_user).and_return('current_user')
      configurer_class = double('permission_configurer')
      configurer_class.should_receive(:create).with(permission_service, 'current_user')
      permission_service.configure(configurer_class)
    end
  end
end