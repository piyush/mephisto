require File.dirname(__FILE__) + '/../../test_helper'

class Admin::CommentsControllerTest < ActionController::TestCase
  fixtures :contents, :users, :sites, :memberships
  def setup
    @controller = Admin::CommentsController.new
    login_as :quentin
  end

  def test_should_disable_comments_on_article
    post :close, :id => contents(:welcome).id
    assert_equal -1, contents(:welcome).reload.comment_age
    assert_response :success
  end

  def test_should_destroy_comment
    comment = contents(:welcome_comment)
    
    xhr :delete, :destroy, :id => '3', :article_id => '1'
    assert_response :success
    assert_equal [comment], assigns(:comments)
    assert_raise(ActiveRecord::RecordNotFound) { comment.reload }
  end
  
  def test_should_destroy_comments
    comment = contents(:welcome_comment)
    
    xhr :delete, :destroy, :comment => ['3'], :article_id => '1'
    assert_response :success
    assert_equal [comment], assigns(:comments)
    assert_raise(ActiveRecord::RecordNotFound) { comment.reload }
  end

  def test_should_list_comments_on_article
    get :index, :article_id => '1'
    assert_response :success
  end

  def test_should_list_approved_comments_on_article
    get :index, :article_id => '1', :filter => 'approved'
    assert_response :success
  end

  def test_should_list_unapproved_comments_on_article
    get :index, :article_id => '1', :filter => 'unapproved'
    assert_response :success
  end
  
  def test_should_create_comment
    post :create, :article_id => '1', :comment => {}
    assert_response :success
  end
  
  def test_should_edit_comment
    get :edit, :article_id => '1', :id => '3'
    assert_response :success
  end
  
  def test_should_update_comment
    post :update, :article_id => '1', :id => '3', :comment => { :body => 'New body text' }
    assert_response :success
  end
  
  def test_should_approve_comment
    contents(:welcome_comment).update_attribute(:approved, false)
    xhr :post, :approve, :article_id => '1', :id => '3'
    assert_response :success
  end

  def test_should_unapprove_comment
    xhr :post, :unapprove, :article_id => '1', :id => '3'
    assert_response :success
    assert_template 'approve'
  end

end
