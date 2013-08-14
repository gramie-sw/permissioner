require 'spec_helper'

describe Permissioner::ServiceAdditions do

  let(:permission_service_class) do
    permission_service_class = Class.new
    permission_service_class.send(:include, Permissioner::ServiceAdditions)
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

    context 'block not given' do

      it 'should return true if given action allowed' do
        permission_service.allow_actions :comments, :index
        permission_service.allow_action?(:comments, :index).should be_true
      end

      it 'should return true for every action when all actions are allowed' do
        permission_service.allow_actions :comments, :all
        permission_service.allow_action?(:comments, :index).should be_true
      end

      it 'should return true if action is allowed and given filter returns true' do
        permission_service.add_filter :comments, :index, &Proc.new { true }
        permission_service.allow_actions :comments, :index
        permission_service.allow_action?(:comments, :index).should be_true
      end

      it 'should return false if given action not allowed' do
        permission_service.allow_action?(:comments, :index).should be_false
        permission_service.allow_actions :comments, :create
        permission_service.allow_action?(:comments, :index).should be_false
      end

      it 'should return false if action is allowed and given filter returns false' do
        permission_service.add_filter :comments, :index, &Proc.new { false }
        permission_service.allow_actions :comments, :index
        permission_service.allow_action?(:comments, :index).should be_false
      end
    end

    context 'block given' do

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

      it 'should return true if block and given filter returns true' do
        permission_service.add_filter :comments, :index, &Proc.new { true }
        permission_service.allow_actions :comments, :index, &Proc.new { true }
        permission_service.allow_action?(:comments, :index, 'current_resource').should be_true
      end

      it 'should return false when block returns false' do
        block = Proc.new { false }
        permission_service.allow_actions :comments, :index, &block
        permission_service.allow_action?(:comments, :index, 'resource').should be_false
      end

      it 'should return true if block and given filter returns true' do
        permission_service.add_filter :comments, :index, &Proc.new { false }
        permission_service.allow_actions :comments, :index, &Proc.new { true }
        permission_service.allow_action?(:comments, :index, 'current_resource').should be_false
      end

      it 'should return false when no ressource given' do
        block = Proc.new { true }
        permission_service.allow_actions :comments, :index, &block
        permission_service.allow_action?(:comments, :index).should be_false
      end
    end

    it 'should also except arguments as string' do
      permission_service.allow_actions :comments, :index
      permission_service.allow_action?('comments', 'index').should be_true
    end

    it 'should pass arguments to passed_filters? if action is principally allowed' do
      permission_service.allow_actions :comments, :index
      permission_service.should_receive(:passed_filters?).with(:comments, :index, :current_resource, :params)
      permission_service.allow_action?(:comments, :index, :current_resource, :params)
    end

    it 'should have default values for current_resource and params' do
      permission_service.allow_actions :comments, :index
      permission_service.should_receive(:passed_filters?).with(:comments, :index, nil, {})
      permission_service.allow_action?(:comments, :index)
    end
  end

  describe '#passed_filters?' do

    it 'should return true when all blocks for given controller and action returns true' do
      permission_service.add_filter(:comments, :create, &Proc.new { true })
      permission_service.passed_filters?(:comments, :create, 'params', 'current_resource').should be_true
    end

    it 'should return true when no filters are added at all' do
      permission_service.passed_filters?(:comments, :create, 'params', 'current_resource').should be_true
    end

    it 'should return true when for given controller and action no filters has been added' do
      permission_service.add_filter(:comments, :update, &Proc.new {})
      permission_service.passed_filters?(:comments, :create, 'params', 'current_resource').should be_true
    end

    it 'should return false when at least one block for given controller and action returns false' do
      permission_service.add_filter(:comments, :create, &Proc.new { true })
      permission_service.add_filter(:comments, :create, &Proc.new { false })
      permission_service.add_filter(:comments, :create, &Proc.new { true })
      permission_service.passed_filters?(:comments, :create, 'params', 'current_resource').should be_false
    end

    it 'should pass current_resource to the given block' do
      current_resource = Object.new
      permission_service.add_filter(:comments, :create, &Proc.new { |cr, p| cr.should be current_resource })
      permission_service.passed_filters?(:comments, :create, current_resource, 'params')
    end

    it 'should pass params to the given block' do
      params = Object.new
      permission_service.add_filter(:comments, :create, &Proc.new { |cr, p| p.should be params })
      permission_service.passed_filters?(:comments, :create, 'current_resource', params)
    end

    it 'should set default values for params and current resource' do
      block = Proc.new do |current_resource, params|
        current_resource.should be_nil
        params.should eq({})
      end
      permission_service.add_filter(:comments, :create, &block)
      permission_service.passed_filters?(:comments, :create)
    end
  end

  describe '#allow_attribute?' do

    it 'should return true when @allow_all is true' do
      permission_service.allow_all
      permission_service.allow_attribute?(:comment, :user_id).should be_true
    end

    it 'should return true when attribute is allowed' do
      permission_service.allow_attributes(:comment, :user_id)
      permission_service.allow_attribute?(:comment, :user_id).should be_true
    end

    it 'should return false when attribute not allowed' do
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

    it 'should add resource and attributes to @allowed_params if multiple given' do
      permission_service.allow_attributes [:comment, :post], [:user, :text]
      allowed_params = permission_service.instance_variable_get(:@allowed_attributes)
      allowed_params.count.should eq 2
      allowed_params[:comment].should eq [:user, :text]
      allowed_params[:post].should eq [:user, :text]
    end

    it 'should add resource and attributes to @allowed_params if attributes is a Hash' do
      permission_service.allow_attributes :comment, {attributes: [:user, :text]}
      allowed_params = permission_service.instance_variable_get(:@allowed_attributes)
      allowed_params.count.should eq 1
      allowed_params[:comment].should eq [{attributes: [:user, :text]}]
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

  describe '#clear_filters' do

    before :each do
      permission_service.add_filter [:users, :comments], [:edit, :update], &Proc.new {}
    end

    it 'should delete filters for actions if one controller and action are given' do
      permission_service.clear_filters :users, :edit
      filters = permission_service.instance_variable_get(:@filters)
      filters.count.should eq 3
      filters.should_not have_key([:users, :edit])
    end

    it 'should delete filters for actions if multiple controllers and actions are given' do
      permission_service.clear_filters [:users, :comments], [:edit, :update]
      filters = permission_service.instance_variable_get(:@filters)
      filters.should be_empty
    end

  end

  describe '#clear_all_filters' do

    it 'should set @filters to nil' do
      permission_service.add_filter(:comments, :create, &Proc.new {})
      permission_service.instance_variable_get(:@filters).should_not be_nil
      permission_service.clear_all_filters
      permission_service.instance_variable_get(:@filters).should be_nil
    end
  end

  describe '#configure' do

    it 'should create new instance of given configurer class' do
      permission_service.stub(:current_user).and_return('current_user')
      configurer_class = double('permission_configurer')
      configurer_class.should_receive(:new).with(permission_service, 'current_user')
      permission_service.configure(configurer_class)
    end
  end
end