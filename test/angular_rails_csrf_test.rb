require 'test_helper'

class AngularRailsCsrfTest < ActionController::TestCase
  tests ApplicationController

  test "a get sets the XSRF-TOKEN cookie but does not require the X-XSRF-TOKEN header" do
    get :index
    assert_valid_cookie
    assert_response :success
  end

  test "a post raises an error without the X-XSRF-TOKEN header set" do
    assert_raises ActionController::InvalidAuthenticityToken do
      post :create
    end
  end

  test "a post raises an error with the X-XSRF-TOKEN header set to the wrong value" do
    set_header_to 'garbage'
    assert_raises ActionController::InvalidAuthenticityToken do
      post :create
    end
  end

  test "a post is accepted if X-XSRF-TOKEN is set properly" do
    set_header_to @controller.send(:form_authenticity_token)
    post :create
    assert_valid_cookie
    assert_response :success
  end

  test "the domain is used if present" do
    config = Rails.application.config
    def config.angular_rails_csrf_domain; :all; end

    get :index
    assert @response.headers['Set-Cookie'].include?('.test.host')
    assert_valid_cookie
    assert_response :success
  end

  private

  # Helpers

  def set_header_to(value)
    @request.headers['X-XSRF-TOKEN'] = value
  end

  def assert_valid_cookie
    if @controller.respond_to?(:valid_authenticity_token?, true)
      assert @controller.send(:valid_authenticity_token?, session, cookies['XSRF-TOKEN'])
    else
      assert_equal @controller.send(:form_authenticity_token), cookies['XSRF-TOKEN']
    end
  end
end
