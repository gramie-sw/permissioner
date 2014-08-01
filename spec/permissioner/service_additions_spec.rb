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
      expect_any_instance_of(permission_service_class).to receive(:configure_permissions).once
      permission_service_class.new
    end

    it 'should set current_user' do
      permission_service = permission_service_class.new 'current_user'
      expect(permission_service.current_user).to eq 'current_user'
    end
  end

  describe '#allow_action?' do

    context 'filters not given' do

      it 'should return true if action is allowed' do
        permission_service.allow_actions :comments, :index
        expect(permission_service.allow_action?(:comments, :index)).to be_truthy
      end

      it 'should return true for every action if  all actions of controller are allowed' do
        permission_service.allow_actions :comments, :all
        expect(permission_service.allow_action?(:comments, :index)).to be_truthy
      end

      it 'should return true if allow_all is true' do
        permission_service.allow_all
        expect(permission_service.allow_action?(:comments, :index)).to be_truthy
      end

      it 'should return false if actions is not allowed' do
        expect(permission_service.allow_action?(:comments, :index)).to be_falsey
      end
    end

    context 'filters given' do

      it 'should return true if action is allowed and all filters return true' do
        permission_service.allow_actions :comments, :index, &Proc.new { true }
        permission_service.add_filter :comments, :index, &Proc.new { true }
        expect(permission_service.allow_action?(:comments, :index)).to be_truthy
      end

      it 'should return true for every action if all actions of controller are allowed and filters return true' do
        permission_service.allow_actions :comments, :all
        permission_service.add_filter :comments, :index, &Proc.new { true }
        expect(permission_service.allow_action?(:comments, :index)).to be_truthy
      end

      it 'should return true if allow_all is true but filters return false' do
        permission_service.allow_all
        permission_service.allow_actions :comments, :index, &Proc.new { false }
        permission_service.add_filter :comments, :index, &Proc.new { false }
        expect(permission_service.allow_action?(:comments, :index)).to be_truthy
      end

      it 'should return false if given action allowed but filters return false' do
        permission_service.allow_actions :comments, :index, &Proc.new { false }
        expect(permission_service.allow_action?(:comments, :index)).to be_falsey
      end

      it 'should return false if given action allowed but at least one filter returns false' do
        permission_service.allow_actions :comments, :index, &Proc.new { true }
        permission_service.add_filter :comments, :index, &Proc.new { false }
        expect(permission_service.allow_action?(:comments, :index)).to be_falsey
      end

      it 'should return false for every action if all actions of controller are allowed but filters return false' do
        permission_service.allow_actions :comments, :all
        permission_service.add_filter :comments, :index, &Proc.new { false }
        expect(permission_service.allow_action?(:comments, :index)).to be_falsey
      end
    end

    it 'should also except arguments as string' do
      permission_service.allow_actions :comments, :index
      expect(permission_service.allow_action?('comments', 'index')).to be_truthy
    end

    it 'should pass arguments to passed_filters? if action is principally allowed' do
      permission_service.allow_actions :comments, :index
      expect(permission_service).to receive(:passed_filters?).with(:comments, :index, resource: :resource, params: :params)
      permission_service.allow_action?(:comments, :index, resource: :resource, params: :params)
    end
  end

  describe '#passed_filters?' do

    it 'should return true when all blocks for given controller and action returns true' do
      permission_service.add_filter(:comments, :create, &Proc.new { true })
      expect(permission_service.passed_filters?(:comments, :create)).to be_truthy
    end

    it 'should return true when no filters are added at all' do
      expect(permission_service.passed_filters?(:comments, :create)).to be_truthy
    end

    it 'should return true when for given controller and action no filters has been added' do
      permission_service.add_filter(:comments, :update, &Proc.new {})
      expect(permission_service.passed_filters?(:comments, :create)).to be_truthy
    end

    it 'should return false when at least one block for given controller and action returns false' do
      permission_service.add_filter(:comments, :create, &Proc.new { true })
      permission_service.add_filter(:comments, :create, &Proc.new { false })
      permission_service.add_filter(:comments, :create, &Proc.new { true })
      expect(permission_service.passed_filters?(:comments, :create)).to be_falsey
    end

    it 'should pass resource to the given block' do
      resource = Object.new
      permission_service.add_filter(:comments, :create, &Proc.new { |r, p| expect(r).to be resource })
      permission_service.passed_filters?(:comments, :create, resource: resource)
    end

    it 'should pass params to the given block' do
      params = Object.new
      permission_service.add_filter(:comments, :create, &Proc.new { |r, p| expect(p).to be params })
      permission_service.passed_filters?(:comments, :create, params: params)
    end

    it 'should set params to {} if not given' do
      permission_service.add_filter(:comments, :create, &Proc.new { |r, p| expect(p).to eq({}) })
      permission_service.passed_filters?(:comments, :create)
    end

    it 'should set params to {} if nil' do
      permission_service.add_filter(:comments, :create, &Proc.new { |r, p| expect(p).to eq({}) })
      permission_service.passed_filters?(:comments, :create, params: nil)
    end

    it 'should set default values for params and current resource' do
      block = Proc.new do |current_resource, params|
        expect(current_resource).to be_nil
        expect(params).to eq({})
      end
      permission_service.add_filter(:comments, :create, &block)
      permission_service.passed_filters?(:comments, :create)
    end
  end

  describe '#allow_attribute?' do

    it 'should return true when @allow_all is true' do
      permission_service.allow_all
      expect(permission_service.allow_attribute?(:comment, :user_id)).to be_truthy
    end

    it 'should return true when attribute is allowed' do
      permission_service.allow_attributes(:comment, :user_id)
      expect(permission_service.allow_attribute?(:comment, :user_id)).to be_truthy
    end

    it 'should return false when attribute not allowed' do
      expect(permission_service.allow_attribute?(:comment, :user_id)).to be_falsey
    end
  end

  describe '#permit_params!' do

    context 'if @allow_all is true' do

      it 'should call permit! on given params when @allow_all is true' do
        params = double('params')
        expect(params).to receive(:permit!)
        permission_service.allow_all
        permission_service.permit_params!(params)
      end
    end

    context 'if @allow_all is false' do

      it 'should permit allow params' do
        permission_service.allow_attributes(:comment, [:user_id, :text])
        permission_service.allow_attributes(:post, [:title, :content])

        params = ActionController::Parameters.new({
                                                      comment: {user_id: '12', text: 'text', date: 'date'},
                                                      post: {title: 'title', content: 'content'}
                                                  })

        permission_service.permit_params!(params)

        expect(params[:comment]).to be_permitted
        expect(params[:comment]).to include :user_id, :text
        expect(params[:comment]).not_to include :date
        expect(params[:post]).to be_permitted
        expect(params[:post]).to include :title, :content
      end
    end

  end

  describe '#allow_all' do

    it 'should set @allow_all to true' do
      permission_service.allow_all
      expect(permission_service.instance_variable_get(:@allow_all)).to be_truthy
    end
  end

  describe '#allow_actions' do

    context 'block not given' do

      it 'should add actions to @allowed_actions when one action is given' do
        permission_service.allow_actions :comments, :index
        allowed_actions = permission_service.instance_variable_get(:@allowed_actions)
        expect(allowed_actions.count).to eq 1
        expect(allowed_actions[['comments', 'index']]).to be_truthy
      end

      it 'should add actions to @allowed_actions when multiple actions are given' do
        permission_service.allow_actions([:comments, :users], [:index, :create])
        allowed_actions = permission_service.instance_variable_get(:@allowed_actions)
        expect(allowed_actions.count).to eq 4
        expect(allowed_actions[['comments', 'index']]).to be_truthy
        expect(allowed_actions[['comments', 'create']]).to be_truthy
        expect(allowed_actions[['users', 'index']]).to be_truthy
        expect(allowed_actions[['users', 'create']]).to be_truthy
      end

      it 'should not add any filters' do
        permission_service.allow_actions :comments, :index
        filters = permission_service.instance_variable_get(:@filters)
        expect(filters.count).to eq 0
      end
    end

    context 'block given' do

      it 'should add block to @filters one aciton is given' do
        block = Proc.new {}
        permission_service.allow_actions :comments, :index, &block
        filters = permission_service.instance_variable_get(:@filters)
        expect(filters.count).to eq 1
        expect(filters[['comments', 'index']]).to eq [block]
      end

      it 'should add block to @filters when multiple actions are given' do
        block = Proc.new {}
        permission_service.allow_actions([:comments, :users], [:index, :create], &block)
        filters = permission_service.instance_variable_get(:@filters)
        expect(filters.count).to eq 4
        expect(filters[['comments', 'index']]).to eq [block]
        expect(filters[['comments', 'create']]).to eq [block]
        expect(filters[['users', 'index']]).to eq [block]
        expect(filters[['users', 'create']]).to eq [block]
      end

      it 'should add multiple blocks to @filters fore every actions' do
        block_1 = Proc.new {}
        block_2 = Proc.new {}
        permission_service.allow_actions :comments, :index, &block_1
        permission_service.allow_actions :comments, :index, &block_2
        filters = permission_service.instance_variable_get(:@filters)
        expect(filters.count).to eq 1
        expect(filters[['comments', 'index']]).to eq [block_1, block_2]
      end

      it 'should add actions to @allowed_actions' do
        permission_service.allow_actions :comments, :index, &Proc.new {}
        allowed_actions = permission_service.instance_variable_get(:@allowed_actions)
        expect(allowed_actions.count).to eq 1
        expect(allowed_actions[['comments', 'index']]).to be_truthy
      end

      it 'should raise error if block is given for all actions' do
        message = 'cannot add filter to :all'
        expect {
          permission_service.allow_actions :comments, :all, &Proc.new {}
        }.to raise_exception message
        expect {
          permission_service.allow_actions :comments, 'all', &Proc.new {}
        }.to raise_exception message
      end
    end
  end

  describe '#allow_attributes' do

    it 'should add resource and attribute to @allowed_params' do
      permission_service.allow_attributes :comment, :text
      allowed_params = permission_service.instance_variable_get(:@allowed_attributes)
      expect(allowed_params.count).to eq 1
      expect(allowed_params[:comment]).to eq [:text]
    end

    it 'should add resource and attributes to @allowed_params if multiple given' do
      permission_service.allow_attributes [:comment, :post], [:user, :text]
      allowed_params = permission_service.instance_variable_get(:@allowed_attributes)
      expect(allowed_params.count).to eq 2
      expect(allowed_params[:comment]).to eq [:user, :text]
      expect(allowed_params[:post]).to eq [:user, :text]
    end

    it 'should add resource and attributes to @allowed_params if attributes is a Hash' do
      permission_service.allow_attributes :comment, {attributes: [:user, :text]}
      allowed_params = permission_service.instance_variable_get(:@allowed_attributes)
      expect(allowed_params.count).to eq 1
      expect(allowed_params[:comment]).to eq [{attributes: [:user, :text]}]
    end
  end

  describe '#add_filter' do

    it 'should add given block to @filters addressed by controller and action' do
      block = Proc.new {}
      permission_service.add_filter(:comments, :create, &block)
      filter_list = permission_service.instance_variable_get(:@filters)[['comments', 'create']]
      expect(filter_list.count).to eq 1
      expect(filter_list).to include block
    end

    it 'should add given block to @filters addressed by controller and action when multiple given' do
      block = Proc.new {}
      permission_service.add_filter([:comments, :posts], [:create, :update], &block)
      expect(permission_service.instance_variable_get(:@filters)[['comments', 'create']]).to include block
      expect(permission_service.instance_variable_get(:@filters)[['comments', 'update']]).to include block
      expect(permission_service.instance_variable_get(:@filters)[['posts', 'create']]).to include block
      expect(permission_service.instance_variable_get(:@filters)[['posts', 'update']]).to include block
    end

    it 'should add multiple blocks to @filters addressed by controller and action' do
      block_1 = Proc.new { 'block 1' }
      block_2 = Proc.new { 'block 2' }
      permission_service.add_filter(:comments, :create, &block_1)
      permission_service.add_filter(:comments, :create, &block_2)
      filter_list = permission_service.instance_variable_get(:@filters)[['comments', 'create']]
      expect(filter_list.count).to eq 2
      expect(filter_list).to include block_1
      expect(filter_list).to include block_2
    end

    it 'should rails exception when no block given' do
      expect { permission_service.add_filter(:comments, :index) }.to raise_error('no block given')
    end

    it 'should raise error if block is given for all actions' do
      message = 'cannot add filter to :all'
      expect {
        permission_service.add_filter :comments, :all, &Proc.new {}
      }.to raise_exception message
      expect {
        permission_service.add_filter :comments, 'all', &Proc.new {}
      }.to raise_exception message
    end
  end

  describe '#clear_filters' do

    before :each do
      permission_service.add_filter [:users, :comments], [:edit, :update], &Proc.new {}
    end

    it 'should delete filters for actions if one controller and action are given' do
      permission_service.clear_filters :users, :edit
      filters = permission_service.instance_variable_get(:@filters)
      expect(filters.count).to eq 3
      expect(filters).not_to have_key([:users, :edit])
    end

    it 'should delete filters for actions if multiple controllers and actions are given' do
      permission_service.clear_filters [:users, :comments], [:edit, :update]
      filters = permission_service.instance_variable_get(:@filters)
      expect(filters).to be_empty
    end

  end

  describe '#clear_all_filters' do

    it 'should set @filters to nil' do
      permission_service.add_filter(:comments, :create, &Proc.new {})
      expect(permission_service.instance_variable_get(:@filters)).not_to be_nil
      permission_service.clear_all_filters
      expect(permission_service.instance_variable_get(:@filters)).to be_nil
    end
  end

  describe '#configure' do

    it 'should create new instance of given configurer class' do
      allow(permission_service).to receive(:current_user).and_return('current_user')
      configurer_class = double('permission_configurer')
      expect(configurer_class).to receive(:new).with(permission_service, 'current_user')
      permission_service.configure(configurer_class)
    end
  end
end