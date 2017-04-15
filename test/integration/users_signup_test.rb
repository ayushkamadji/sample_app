require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup information" do
    get signup_path

    assert_no_difference 'User.count' do
      assert_select 'form[action=?]', "/signup"
      post signup_path, params: {user: {name: "",
                                       email: "foo@bar",
                                       password: "foo",
                                       password_confirmation: "bar"}}
    end

    assert_template 'users/new'
    assert_select 'div#error_explanation', /The form contains \d error(s)?/ 
    assert_select 'div.field_with_errors', 8
  end

  test "valid signup information with account activation" do
    get signup_path
    
    assert_difference 'User.count', 1 do
      post signup_path, params: {user: {name: "foo",
                                        email: "foo@bar.net",
                                        password: "123456",
                                        password_confirmation: "123456"
                                       }
                                }
    end

    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    
    # Login before activation
    log_in_as(user)
    assert_not is_logged_in?

    # Activate with invalid token
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    assert_not user.reload.activated?

    # Activate with invalid email
    get edit_account_activation_path(user.activation_token, email: "invalid")

    assert_not is_logged_in?
    assert_not user.reload.activated?

    # Valid activation
    get edit_account_activation_path(user.activation_token,
                                     email: user.email)
    assert user.reload.activated?
    assert is_logged_in?


    follow_redirect!
    assert_not flash.empty?
  # assert_template 'users/show'
  # assert is_logged_in?
  end
end
