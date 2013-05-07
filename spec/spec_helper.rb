require 'active_support/core_ext/object/try'
require 'active_support/core_ext/module/delegation'
require 'permissioner'
require 'permissioner/matchers'


class PermissionService

  include Permissioner::PermissionServiceAdditions
end
