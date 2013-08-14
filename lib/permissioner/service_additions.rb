module Permissioner
  module ServiceAdditions

    attr_accessor :current_user

    def initialize current_user=nil
      @current_user = current_user
      configure_permissions
    end

    def allow_action?(controller, action, current_resource=nil, params={})
      allowed =
          @allow_all ||
          (@allowed_actions &&
              (@allowed_actions[[controller.to_s, action.to_s]] || @allowed_actions[[controller.to_s, 'all']]))
      allowed = allowed && (allowed == true || current_resource && allowed.call(current_resource))
      allowed && passed_filters?(controller, action, current_resource, params)
    end

    def allow_attribute?(resource, attribute)
      @allow_all || @allowed_attributes && @allowed_attributes[resource].try(:include?, attribute)
    end

    def passed_filters?(controller, action, current_resource=nil, params={})
      if @filters && @filters[[controller.to_s, action.to_s]]
        @filters[[controller.to_s, action.to_s]].all? { |block| block.call(current_resource, params) }
      else
        true
      end
    end

    def permit_params!(params)
      if @allow_all
        params.permit!
      elsif @allowed_attributes
        @allowed_attributes.each do |resource, attributes|
          if params[resource].respond_to? :permit
            params[resource] = params[resource].permit(*attributes)
          end
        end
      end
    end

    def allow_all
      @allow_all = true
    end

    #Adds the given actions to the list of allowed actions.
    #The first argument is the controller, the second is the action.
    #You can allow a single action or multiple actions at once:
    #
    #   allow_actions :comments, :index
    #   allow_actions [:comments, :posts], [:index, :create, :update]
    #
    #If a block is given it is stored for the given action and will be evaluated every time the authorization for the
    #action runs. If the block returns true the action is allowed otherwise not. The current_resource will be put
    #in the block.
    #
    def allow_actions(controllers, actions, &block)
      @allowed_actions ||= {}
      Array(controllers).each do |controller|
        Array(actions).each do |action|
          @allowed_actions[[controller.to_s, action.to_s]] = block || true
        end
      end
    end

    def allow_attributes(resources, attributes)
      @allowed_attributes ||= {}
      Array(resources).each do |resource|
        @allowed_attributes[resource] ||= []
        if attributes.is_a?(Hash)
          @allowed_attributes[resource] << attributes
        else
          @allowed_attributes[resource] += Array(attributes)
        end
      end
    end

    def add_filter(controllers, actions, &block)
      raise 'no block given' unless block_given?
      @filters ||= {}
      Array(controllers).each do |controller|
        Array(actions).each do |action|
          @filters[[controller.to_s, action.to_s]] ||= []
          @filters[[controller.to_s, action.to_s]] << block
        end
      end
    end

    def clear_all_filters
      @filters = nil
    end

    def clear_filters controllers, actions
      Array(controllers).each do |controller|
        Array(actions).each do |action|
          @filters.delete([controller.to_s, action.to_s])
        end
      end
    end

    # Configures permissions by instantiate a new object of the given class which is intended to include
    # the module Permissioner::PermissionConfigurer.
    #
    def configure configurer_class
      configurer_class.new(self, current_user)
    end

    # Should be overwritten by the including class and is called during initialization in ::create.
    # This the intended place where permissions should be configured.
    #
    def configure_permissions
    end
  end
end