require 'spec_helper'

describe Permissioner::Matchers::ExactlyAllowControllers do

  let(:permission_service) do
    permission_service = PermissionService.new
    permission_service.allow_actions :comments, :index
    permission_service.allow_actions :comments, :create
    permission_service.allow_actions :users, :index
    permission_service.allow_actions :posts, :update
    permission_service
  end

  def create_matcher(*expected_controllers)
    Permissioner::Matchers::ExactlyAllowControllers.new(*expected_controllers)
  end

  describe '#initialize' do

    it 'should transform expected_controllers to strings' do
      matcher = create_matcher(:comments, :users)
      matcher.instance_variable_get(:@expected_controllers).should eq ['comments', 'users']
    end
  end

  describe '#matches?' do

    it 'should return true if exactly all expected controllers allowed' do
      matcher = create_matcher(:comments, :users, :posts)
      matcher.matches?(permission_service).should be_true
    end

    it 'should return false if one controller is not allowed' do
      matcher = create_matcher(:comments, :users, :posts, :blogs)
      matcher.matches?(permission_service).should be_false
    end

    it 'should return true if more controllers allowed than expected' do
      matcher = create_matcher(:comments, :users)
      matcher.matches?(permission_service).should be_false
    end

    it 'should work if no controller allowed' do
      matcher = create_matcher(:comments, :users)
      matcher.matches?(PermissionService.new).should be_false
    end
  end

  describe '#failure_message_for_should' do

    it 'should be available' do
      matcher = create_matcher(:comments)
      expected_messages =
          "expected to exactly allow controllers \n" \
          "[\"comments\"] are allowed, but found controllers\n"\
          "[\"comments\", \"users\", \"posts\"] allowed"
      matcher.failure_message_for_should(permission_service).should eq expected_messages
    end

    it 'should work  if no controller allowed' do
      matcher = create_matcher(:comments)
      matcher.failure_message_for_should(PermissionService.new).should be_kind_of(String)
    end
  end

  describe '#failure_message_for_should_not' do

    it 'should be available' do
      matcher = create_matcher(:comments, :users)
      expected_messages =
          "expected to exactly not allow controllers \n" \
          "[\"comments\", \"users\"], but these controllers are exactly allowed\n"
      matcher.failure_message_for_should_not(permission_service).should eq expected_messages
    end

    it 'should work if no controller allowed' do
      matcher = create_matcher(:comments, :users)
      matcher.failure_message_for_should_not(PermissionService.new).should be_kind_of(String)
    end
  end

end