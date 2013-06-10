RSpec::Matchers.define :allow_action do |*args|
  match do |permission_service|
    permission_service.allow_action?(*args)
  end
end

RSpec::Matchers.define :allow_attribute do |*args|
  match do |permission_service|
    permission_service.allow_attribute?(*args)
  end
end
RSpec::Matchers.define :pass_filters do |controller, action, params={}|
  match do |permission_service|
    permission_service.passed_filters?(controller, action, params)
  end
end