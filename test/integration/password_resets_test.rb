require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:example)
    get new_password_reset_path
  end

  def submit_forgot_form(email)
    post password_resets_path, params: {password_reset: {email: email}}
  end

  def get_user_by_form_submission(email)
    submit_forgot_form(email)
    assigns(:user)
  end

  test "new request should render forgot password page" do
    assert_template 'password_resets/new'
  end

  test "request password reset with invalid email" do
    submit_forgot_form("")
    assert_not flash.empty?
    assert_template 'password_resets/new'
  end

  test "request password reset with valid email" do
    submit_forgot_form("example@example.org")
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.count
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "reset password link with wrong email" do
    user = get_user_by_form_submission("example@example.org")
    assert user.reset_token
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url
  end

  test "reset password link by unactivated user" do
    user = get_user_by_form_submission("example@example.org")
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
  end

  test "reset password link with expired link" do
    user = get_user_by_form_submission("example@example.org")
    user.update_attribute(:reset_sent_at, 2.hours.ago - 1)
    get edit_password_reset_path(user.reset_token, email:user.email)
    assert_response :redirect
    follow_redirect!
    assert_match /expired/i, response.body
  end

  test "reset password link, right email, wrong token" do
    user = get_user_by_form_submission("example@example.org")
    get edit_password_reset_path("wrong token", email: user.email)
    assert_redirected_to root_url
  end

  test "resset password link, right email, right token" do
    user = get_user_by_form_submission("example@example.org")
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select 'input[type=hidden][name=email][value=?]', user.email
  end

  test "resseting password form, invalid password & confirmation" do
    user = get_user_by_form_submission("example@example.org")
    patch password_reset_path(user.reset_token), 
      params: {email: user.email,
               user: {password: "123",
                      password_confirmation: "abc"}}
    assert_template 'password_resets/edit'
    assert_select 'div#error_explanation'
  end

  test "resetting password form, with empty password" do
    user = get_user_by_form_submission("example@example.org")
    patch password_reset_path(user.reset_token), 
      params: {email: user.email,
               user: {password: "",
                      password_confirmation: "abc"}}
    assert_template 'password_resets/edit'
    assert_select 'div#error_explanation'
  end

  test "resetting password form, sucessful reset" do
    user = get_user_by_form_submission("example@example.org")
    patch password_reset_path(user.reset_token), 
      params: {email: user.email,
               user: {password: "foobar",
                      password_confirmation: "foobar"}}
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end

  test "reset password link, after link successfully used to reset" do
    user = get_user_by_form_submission("example@example.org")
    patch password_reset_path(user.reset_token), 
      params: {email: user.email,
               user: {password: "foobar",
                      password_confirmation: "foobar"}}
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    assert_nil user.reload.reset_digest
  end
end
