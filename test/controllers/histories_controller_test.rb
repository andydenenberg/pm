require 'test_helper'

class HistoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @history = histories(:one)
  end

  test "should get index" do
    get histories_url
    assert_response :success
  end

  test "should get new" do
    get new_history_url
    assert_response :success
  end

  test "should create history" do
    assert_difference('History.count') do
      post histories_url, params: { history: { cash: @history.cash, daily_dividend: @history.daily_dividend, daily_dividend_date: @history.daily_dividend_date, options: @history.options, options_count: @history.options_count, portfolio_id: @history.portfolio_id, snapshot_date: @history.snapshot_date, stocks: @history.stocks, stocks_count: @history.stocks_count, total: @history.total } }
    end

    assert_redirected_to history_url(History.last)
  end

  test "should show history" do
    get history_url(@history)
    assert_response :success
  end

  test "should get edit" do
    get edit_history_url(@history)
    assert_response :success
  end

  test "should update history" do
    patch history_url(@history), params: { history: { cash: @history.cash, daily_dividend: @history.daily_dividend, daily_dividend_date: @history.daily_dividend_date, options: @history.options, options_count: @history.options_count, portfolio_id: @history.portfolio_id, snapshot_date: @history.snapshot_date, stocks: @history.stocks, stocks_count: @history.stocks_count, total: @history.total } }
    assert_redirected_to history_url(@history)
  end

  test "should destroy history" do
    assert_difference('History.count', -1) do
      delete history_url(@history)
    end

    assert_redirected_to histories_url
  end
end
