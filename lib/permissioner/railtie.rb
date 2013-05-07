module Permissioner
  class Railtie < Rails::Railtie

    initializer "permissioner.controller_additions" do
      ActionController::Base.send :include, ControllerAdditions
    end
  end
end