module Permissioner
  module ControllerAdditions

    def self.included(base)
      base.helper_method :allow_action?, :allow_attribute?
      base.delegate :allow_action?, :allow_attribute?, to: :permission_service
    end

    def authorize
      if permission_service.allow_action?(params[:controller], params[:action], current_resource) &&
          permission_service.passed_filters?(params[:controller], params[:action], params)
        permission_service.permit_params!(params)
      else
        raise Permissioner::NotAuthorized
      end
    end

    def permission_service
      @permission_service ||= PermissionService.create(current_user)
    end

    def current_resource
      nil
    end
  end
end