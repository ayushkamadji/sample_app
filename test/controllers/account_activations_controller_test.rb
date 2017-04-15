require 'test_helper'

class AccountActivationsControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  test "successful activation should update activation attributes" do
    user = users(:verynew)
    simulate_activation_digest_creation(user)
    assert user.activation_token
    assert user.activation_digest

    get edit_account_activation_path(user.activation_token, 
                                     email: user.email)

    user.reload
    assert user.activated?
    assert_not user.activated_at.nil?
  end
end
