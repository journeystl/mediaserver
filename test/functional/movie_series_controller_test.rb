require 'test_helper'

class MovieSeriesControllerTest < ActionController::TestCase
  setup do
    @movie_series = movie_series(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:movie_series)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create movie_series" do
    assert_difference('MovieSeries.count') do
      post :create, :movie_series => @movie_series.attributes
    end

    assert_redirected_to movie_series_path(assigns(:movie_series))
  end

  test "should show movie_series" do
    get :show, :id => @movie_series.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @movie_series.to_param
    assert_response :success
  end

  test "should update movie_series" do
    put :update, :id => @movie_series.to_param, :movie_series => @movie_series.attributes
    assert_redirected_to movie_series_path(assigns(:movie_series))
  end

  test "should destroy movie_series" do
    assert_difference('MovieSeries.count', -1) do
      delete :destroy, :id => @movie_series.to_param
    end

    assert_redirected_to movie_series_index_path
  end
end
