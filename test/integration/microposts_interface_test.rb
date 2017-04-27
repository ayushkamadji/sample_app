require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:example)
  end

  test "micropost interface" do
    log_in_as(@user)

    get root_path

    assert_template 'static_pages/home'
    assert_select 'div.pagination'
    assert_select 'input[type=file]'

    # Invalid submission
    assert_no_difference 'Micropost.count' do 
      post microposts_path, params: {micropost: {content: "  "}}
    end

    assert_template 'static_pages/home'
    assert_select 'div.field_with_errors'
    assert_select 'div#error_explanation'

    # Valid submission
    content = "Hi there" 
    picture = fixture_file_upload('test/fixtures/rails.png', 'image/png')
    assert_difference 'Micropost.count' do
      post microposts_path, params: {micropost: {content: content, picture: picture }}
    end

    assert assigns(:micropost).picture?
    assert_redirected_to root_url
    follow_redirect!
    assert_template 'static_pages/home'
    assert_not flash.empty?
    assert_match content, response.body

    # Delete post
    assert_select 'a', text: "delete"
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end

    # Visit another users page (no delete links)
    get user_path(users(:archer))
    assert_select 'a', text: "delete", count: 0
  end

  test "Micropost sidebar count" do
    log_in_as(@user)
    get root_path
    assert_match "#{@user.microposts.count} microposts", response.body

    other_user = users(:foobar)
    log_in_as(other_user)
    get root_path
    assert_match "0 microposts", response.body

    other_user.microposts.create(content: "Heelloo there")
    get root_path
    assert_match "1 micropost", response.body
  end
end
