require 'spec_helper'

describe Permissioner::Matchers::ExactlyAllowAttributes do

  let(:permission_service) do
    permission_service = PermissionService.new
    permission_service.allow_attributes :user, [:name, :email, :phone]
    permission_service.allow_attributes :comment, [:user_id, :post_id, :content]
    permission_service.allow_attributes :post, [:user_id, :content]
    permission_service
  end

  def create_matcher(*expected_attributes)
    Permissioner::Matchers::ExactlyAllowAttributes.new(*expected_attributes)
  end

  describe '#initialize' do

    it 'should ensure that all attributes are into an array' do
      matcher = create_matcher [:resource, :attribute]
      matcher.instance_variable_get(:@all_expected_attributes).should eq [[:resource, [:attribute]]]
      matcher = create_matcher [:resource, [:attribute_1, :attribute_2]]
      matcher.instance_variable_get(:@all_expected_attributes).should eq [[:resource, [:attribute_1, :attribute_2]]]
    end

    it 'should raise an exception if multiple actions not stated as array' do
      expect {
        create_matcher [:resource, :attribute_1, :attribute_2]
      }.to raise_exception 'multiple attributes for a resource must stated as array, e.g. [:user_id, :username]'
    end
  end

  describe '#matches?' do

    context 'on success' do

      it 'should return true if all expected resources with attributes are exactly allowed' do
        matcher = create_matcher(
            [:user, [:name, :email, :phone]],
            [:comment, [:user_id, :post_id, :content]],
            [:post, [:user_id, :content]]
        )
        matcher.matches?(permission_service).should be_true
      end

      it 'should accept attributs being a hash' do
        permission_service = PermissionService.new
        permission_service.allow_attributes(
            :account,
            [
                {user: [:name, :email, :phone]},
                {adresse: [:name, :street_with_number, :zip_code, :city]},
            ]
        )
        matcher = create_matcher(
            [:account,
             [
                 {user: [:name, :email, :phone]},
                 {adresse: [:name, :street_with_number, :zip_code, :city]},
             ]
            ]
        )
        matcher.matches?(permission_service).should be_true
      end
    end

    context 'if resources did not match' do

      it 'should return false if at least one expected resource is not allowed' do
        matcher = create_matcher(
            [:user, [:name, :email, :phone]],
            [:comment, [:user_id, :post_id, :content]],
            [:account, [:user_id, :content]]
        )
        matcher.matches?(permission_service).should be_false
      end

      it 'should return false if at least one resource is allowed but no expected' do
        matcher = create_matcher(
            [:user, [:name, :email, :phone]],
            [:comment, [:user_id, :post_id, :content]]
        )
        matcher.matches?(permission_service).should be_false
      end
    end

    context 'if attributes of ressrouces did not match' do

      it 'should return false if at least one expected attribute is not allowed' do
        matcher = create_matcher(
            [:user, [:name, :email, :phone, :street]],
            [:comment, [:user_id, :post_id, :content]],
            [:post, [:user_id, :content]]
        )
        matcher.matches?(permission_service).should be_false
      end

      it 'should return false if at least one attribute is allowed but not expected' do
        matcher = create_matcher(
            [:user, [:name, :email]],
            [:comment, [:user_id, :post_id, :content]],
            [:post, [:user_id, :content]]
        )
        matcher.matches?(permission_service).should be_false
      end
    end
  end

  describe '#failure_message_for_should_not' do

    it 'should be available' do
      matcher = create_matcher
      expected_messages = 'given attributes are exactly allowed although this is not expected'
      matcher.failure_message_for_should_not.should eq expected_messages
    end

    it 'should be available' do
      matcher = create_matcher
      matcher.matches?(PermissionService.new)
      matcher.failure_message_for_should_not.should be_kind_of(String)
    end
  end

  describe '#failure_message_for_should' do

    context 'if resources did not match' do

      it 'should be available' do
        matcher = create_matcher(
            [:user, []],
            [:comment, []]
        )
        expected_messages =
            "expected to find allowed attributes for resources\n"\
            "[:comment, :user], but found allowed attributes for resources\n"\
            "[:comment, :post, :user]"
        #call is necessary because matches sets @permission_service
        matcher.matches?(permission_service)
        matcher.failure_message_for_should.should eq expected_messages
      end

      it 'should work if no controller allowed' do
        matcher = create_matcher(
            [:user, []],
            [:comment, []],
            [:post, []]
        )
        #call is necessary because matches sets @permission_service
        matcher.matches?(PermissionService.new)
        matcher.failure_message_for_should.should be_kind_of(String)
      end
    end


    context 'if attributes for resources did not match' do

      it 'should be available' do
        matcher = create_matcher(
            [:user, [:name, :email]],
            [:comment, [:user_id, :post_id]],
            [:post, [:user_id, :content]]
        )
        expected_messages =
            "expected attributes did not match for following resources:\n"\
            "user:\n"\
            "[:name, :email] were expected to be allowed, but attributes\n"\
            "[:name, :email, :phone] are allowed\n"\
            "comment:\n"\
            "[:user_id, :post_id] were expected to be allowed, but attributes\n"\
            "[:user_id, :post_id, :content] are allowed\n"
        #call is necessary because matches sets @permission_service
        matcher.matches?(permission_service)
        matcher.failure_message_for_should.should eq expected_messages
      end


      it 'should work if no controller allowed' do
        matcher = create_matcher(
            [:comments, [:show, :new, :create]],
            [:users, [:new, :create, :update]],
            [:posts, [:show, :edit, :update]]
        )
        #call is necessary because matches sets @permission_service
        matcher.matches?(PermissionService.new)
        matcher.failure_message_for_should.should be_kind_of(String)
      end
    end
  end

  #describe '#failure_message_for_should' do
  #
  #  it 'should be available' do
  #    matcher = create_matcher :user, [:name, :email, :street]
  #    expected_messages =
  #        "expected that for resource \"user\" attributes\n"\
  #        "[:name, :email, :street] are exactly allowed, but found attributes\n"\
  #        "[:name, :email, :phone] allowed"
  #    matcher.matches?(permission_service)
  #    matcher.failure_message_for_should.should eq expected_messages
  #  end
  #
  #  it 'should work if no controller allowed' do
  #    matcher = create_matcher :user, [:name, :email, :street]
  #    matcher.matches?(PermissionService.new)
  #    matcher.failure_message_for_should.should be_kind_of(String)
  #  end
  #end
  #
  #describe '#failure_message_for_should_not' do
  #
  #  it 'should be available' do
  #    matcher = create_matcher :user, [:name, :email, :street]
  #    expected_messages =
  #        "expected that for resource \"user\" attributes\n"\
  #        "[:name, :email, :street] are exactly not allowed,\n"\
  #        "but those attributes are exactly allowed\n"
  #    matcher.matches?(permission_service)
  #    matcher.failure_message_for_should_not.should eq expected_messages
  #  end
  #
  #  it 'should work if no controller allowed' do
  #    matcher = create_matcher :user, [:name, :email, :street]
  #    matcher.matches?(PermissionService.new)
  #    matcher.failure_message_for_should_not.should be_kind_of(String)
  #  end
  #end
end
