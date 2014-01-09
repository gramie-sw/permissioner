require 'active_support/core_ext/object/try'
require 'active_support/core_ext/module/delegation'
require 'action_controller'
require 'permissioner'
require 'permissioner/matchers'


class PermissionService
  include Permissioner::ServiceAdditions
end
