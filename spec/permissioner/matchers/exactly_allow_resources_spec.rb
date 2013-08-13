require 'spec_helper'

describe Permissioner::Matchers::ExactlyAllowResources do

  let(:permission_service) do
    permission_service = PermissionService.new
    permission_service.allow_attributes :user, [:name, :email, :phone]
    permission_service.allow_attributes :comment, [:user_id, :text]
    permission_service.allow_attributes :post, [:user_id, :text]
    permission_service
  end


  def create_matcher(*expected_resources)
    Permissioner::Matchers::ExactlyAllowResources.new(*expected_resources)
  end

  describe '#matches?' do

    it 'should return true if given resources exaclty allowed' do
      matcher = create_matcher :user, :comment, :post
      matcher.matches?(permission_service).should be_true
    end

    it 'should return false if at least one resource is not allowed' do
      matcher = create_matcher :user, :comment, :account
      matcher.matches?(permission_service).should be_false
    end

    it 'should return false if more resources allowed than expected' do
      matcher = create_matcher :user, :comment
      matcher.matches?(permission_service).should be_false
    end

    it 'should work if no resource is allowed' do
      matcher = create_matcher :user, :comment
      matcher.matches?(PermissionService.new).should be_false
    end
  end

  describe '#failure_message_for_should' do

    it 'should be available' do
      matcher = create_matcher(:user, :comment)
      expected_messages =
          "expected to exactly allow resources \n" \
          "[:comment, :user], but found resources\n"\
          "[:comment, :post, :user] allowed"
      #call is necessary because matches sets @permission_service
      matcher.matches?(permission_service)
      matcher.failure_message_for_should.should eq expected_messages
    end

    it 'should work if no controller allowed' do
      matcher = create_matcher(:user, :comment)
      #call is necessary because matches sets @permission_service
      matcher.matches?((PermissionService.new))
      matcher.failure_message_for_should.should be_kind_of(String)
    end
  end

  describe '#failure_message_for_should_not' do

    it 'should be available' do
      matcher = create_matcher(:user, :comment)
      expected_messages =
          "expected to exactly not allow resources \n" \
          "[:comment, :user], but these resources are exactly allowed\n"
      matcher.failure_message_for_should_not.should eq expected_messages
    end

    it 'should work if no controller allowed' do
      matcher = create_matcher(:comment, :user)
      matcher.failure_message_for_should_not.should be_kind_of(String)
    end
  end

end