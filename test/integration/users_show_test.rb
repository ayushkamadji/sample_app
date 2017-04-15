require 'test_helper'

class UsersShowTest < ActionDispatch::IntegrationTest
  
  test "should redirect unactivated user to root" do
    unactivated_user = users(:verynew)
    get user_path(unactivated_user)
    assert_redirected_to root_url
  end

  test "should show activated user profile page" do
    activated_user = users(:example)
    get user_path(activated_user)
    assert_response :success
    assert_template 'users/show'
  end
end
