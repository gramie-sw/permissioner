# A sample Guardfile
# More info at https://github.com/guard/guard#readme

notification :notifysend, t: 1000

guard 'rspec', failed_mode: :none, notification: true do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$}) { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb') { "spec" }
end

