require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  test "invalid signup information" do
    get signup_path

    assert_no_difference 'User.count' do
      assert_select "form:match('action',?)", "/signup" 
      post signup_path, params: {user: {name: "",
                                       email: "foo@bar",
                                       password: "foo",
                                       password_confirmation: "bar"}}
    end

    assert_template 'users/new'
    assert_select 'div#error_explanation', /The form contains \d error(s)?/ 
    assert_select 'div.field_with_errors', 8
  end

  test "valid signup information" do
    get signup_path
    
    assert_difference 'User.count', 1 do
      post signup_path, params: {user: {name: "foo",
                                        email: "foo@bar.net",
                                        password: "123456",
                                        password_confirmation: "123456"
                                       }
                                }
    end

    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?
    assert is_logged_in?
  end
end
