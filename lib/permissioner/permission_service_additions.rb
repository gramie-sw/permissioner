module Permissioner
  module PermissionServiceAdditions

    module ClassMethods

      def create current_user
        permission_service = self.new
        permission_service.current_user = current_user
        permission_service.configure_permissions
        permission_service
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    attr_accessor :current_user

    def allow_action?(controller, action, resource = nil)
      allowed = @allow_all || (@allowed_actions && @allowed_actions[[controller.to_s, action.to_s]])
      allowed && (allowed == true || resource && allowed.call(resource))
    end

    def allow_param?(resource, attribute)
      @allow_all || @allowed_params && @allowed_params[resource].try(:include?, attribute)
    end

    def passed_filters?(controller, action, params)
      if @filters && @filters[[controller.to_s, action.to_s]]
        @filters[[controller.to_s, action.to_s]].all? { |block| block.call(params) }
      else
        true
      end
    end

    def permit_params!(params)
      if @allow_all
        params.permit!
      elsif @allowed_params
        @allowed_params.each do |resource, attributes|
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
    #   allow_acitons [:comments, :posts], [:index, :create, :update]
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

    def allow_params(resources, attributes)
      @allowed_params ||= {}
      Array(resources).each do |resource|
        @allowed_params[resource] ||= []
        @allowed_params[resource] += Array(attributes)
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

    # Configures permissions by calling the factory method ::create on the given class which is intended to include
    # the module Permissioner::PermissionConfigurer.
    #
    def configure configurer_class
      configurer_class.create(self, current_user)
    end

    # Should be overwritten by the including class and is called during initialization in ::create.
    # This the intended place where permissions should be configured.
    #
    def configure_permissions
    end
  end
end