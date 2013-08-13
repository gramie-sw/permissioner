require 'spec_helper'

describe Permissioner::Matchers::ExactlyAllowAttributes do

  let(:permission_service) do
    permission_service = PermissionService.new
    permission_service.allow_attributes :user, [:name, :email, :phone]
    permission_service.allow_attributes :comment, [:user_id, :text]
    permission_service
  end

  def create_matcher(resource, expected_attributes)
    Permissioner::Matchers::ExactlyAllowAttributes.new(resource, expected_attributes)
  end

  describe '#initialize' do

    it 'should transform expected_attributes to array' do
      matcher = create_matcher nil, :name
      matcher.instance_variable_get(:@expected_attributes).should eq [:name]
      matcher = create_matcher nil, [:name, :email]
      matcher.instance_variable_get(:@expected_attributes).should eq [:name, :email]
    end
  end

  describe '#matches?' do

    it 'should return true if for given resource exactly all given attributes are allowed' do
      matcher = create_matcher :user, [:name, :email, :phone]
      matcher.matches?(permission_service).should be_true
    end

    it 'should return false if for given resource not all given attributes are allowed' do
      matcher = create_matcher :user, [:name, :email, :street]
      matcher.matches?(permission_service).should be_false
    end

    it 'should return false if for given resource not all allowed attributes are given' do
      matcher = create_matcher :user, [:name, :email]
      matcher.matches?(permission_service).should be_false
    end
  end

  describe '#failure_message_for_should' do

    it 'should be available' do
      matcher = create_matcher :user, [:name, :email, :street]
      expected_messages =
          "expected that for resource \"user\" attributes\n"\
          "[:name, :email, :street] are exactly allowed, but found attributes\n"\
          "[:name, :email, :phone] allowed"
      matcher.matches?(permission_service)
      matcher.failure_message_for_should.should eq expected_messages
    end

    it 'should work if no controller allowed' do
      matcher = create_matcher :user, [:name, :email, :street]
      matcher.matches?(PermissionService.new)
      matcher.failure_message_for_should.should be_kind_of(String)
    end
  end

  describe '#failure_message_for_should_not' do

    it 'should be available' do
      matcher = create_matcher :user, [:name, :email, :street]
      expected_messages =
          "expected that for resource \"user\" attributes\n"\
          "[:name, :email, :street] are exactly not allowed,\n"\
          "but those attributes are exactly allowed\n"
      matcher.matches?(permission_service)
      matcher.failure_message_for_should_not.should eq expected_messages
    end

    it 'should work if no controller allowed' do
      matcher = create_matcher :user, [:name, :email, :street]
      matcher.matches?(PermissionService.new)
      matcher.failure_message_for_should_not.should be_kind_of(String)
    end
  end
end
