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
RSpec::Matchers.define :passed_filters do |*args|
  match do |permission_service|
    permission_service.passed_filters?(*args)
  end
end