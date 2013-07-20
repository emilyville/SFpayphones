require 'test_helper'

class PayPhonesControllerTest < ActionController::TestCase
  setup do
    @pay_phone = pay_phones(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:pay_phones)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create pay_phone" do
    assert_difference('PayPhone.count') do
      post :create, pay_phone: { lat: @pay_phone.lat, lon: @pay_phone.lon, neighborhood: @pay_phone.neighborhood, number: @pay_phone.number }
    end

    assert_redirected_to pay_phone_path(assigns(:pay_phone))
  end

  test "should show pay_phone" do
    get :show, id: @pay_phone
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @pay_phone
    assert_response :success
  end

  test "should update pay_phone" do
    patch :update, id: @pay_phone, pay_phone: { lat: @pay_phone.lat, lon: @pay_phone.lon, neighborhood: @pay_phone.neighborhood, number: @pay_phone.number }
    assert_redirected_to pay_phone_path(assigns(:pay_phone))
  end

  test "should destroy pay_phone" do
    assert_difference('PayPhone.count', -1) do
      delete :destroy, id: @pay_phone
    end

    assert_redirected_to pay_phones_path
  end
end
