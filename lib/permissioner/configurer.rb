module Permissioner

  # This module is intended to be included in a class configuring permissions for a permissions service.
  #
  # The including class should overwrite the instance method configure_permissions in which the can allow actions and
  # attributes and can add filters. In order to support this, this module provides the methods #allow_actions,
  # #allow_attributes and #add_filters which all will be delegated to the permission service.
  #
  # To obtain the signed in user instance call current_user.
  #
  # In order to get an instance of the including class call the class method ::create acting as an factory method and
  # ensures correct initialization.
  #
  # class ManagerPermissions
  #
  #   include Permissioner::PermissionConfigurer
  #
  #   def configure_permissions
  #
  #     if current_user.manager?
  #
  #       allow_actions :projects, :update
  #       allow_attributes: project, [:name, description]
  #     end
  # end
  #
  module Configurer

    attr_reader :current_user, :permission_service
    delegate :allow_actions, :allow_attributes, :add_filter, :clear_filters, to: :permission_service


    # Expects an instance of a class including module Permissioner::PermissionServiceAdditions acting as
    # permission service and current signed in user.
    def initialize permission_service, current_user
      @permission_service = permission_service
      @current_user = current_user
      configure_permissions
    end

    # Should be overwritten by the including class and is called during initialization in ::create.
    # This the intended place where permissions should be configured.
    #
    def configure_permissions
    end
  end
end