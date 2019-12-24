require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    assert_select 'input[type=file]'
    # 無効な送信
    post microposts_path, params: { micropost: { content: "" } }
    assert_select 'div#error_explanation'
    # 有効な送信
    content = "This micropost really ties the room together"
    picture = fixture_file_upload('test/fixtures/rails.png', 'image/png')
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content,
                                                   picture: picture } }
    end
    assert assigns(:micropost).picture?
    follow_redirect!
    assert_match content, response.body
    # 投稿を削除する
    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    # 違うユーザーのプロフィールにアクセス (削除リンクがないことを確認)
    get user_path(users(:archer))
    assert_select 'a', { text: 'delete', count: 0 }
  end
  
  test "reply to other user" do
    log_in_as(@user)
    get root_path
    
    # invalid post(ID doesn't exist)
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: {micropost: {content: "@1000000000000000"}}
    end
    assert_select 'div#error_explanation'
    # invalid post(Reply to yourself)
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: {micropost: {content: "@#{@user.id}-Hoge-Hoge"}}
    end
    assert_select 'div#error_explanation'
    # invalid post(ID doesn't match its user name)
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: {micropost: {content: "@#{@other_user.id}-Hoge-Hoge"}}
    end
    assert_select 'div#error_explanation'
    # valid post
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: {micropost: {content: "@#{@other_user.id}-Sterling-Archer"}}
    end
  end
  
  test "reply post visibility" do
    log_in_as(@user)
    get root_path
    reply_to_user = @other_user
    content = "@#{reply_to_user.id}-Sterling-Archer"
    post microposts_path, params: {micropost: {content: content}}
    follow_redirect!
    assert_match content, response.body
    
    # should be visible
    log_in_as(@other_user)
    get root_path
    assert_match content, response.body
    
    #shouldn't be visible
    third_user = users(:lana)
    log_in_as(third_user)
    get root_path
    assert_no_match content, response.body
  end
end
