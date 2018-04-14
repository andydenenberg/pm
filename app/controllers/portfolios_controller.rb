class PortfoliosController < ApplicationController
  before_action :set_portfolio, only: [:show, :edit, :update, :destroy]

  def index
    if request.xhr?
      if params[:stock_option] == 'Stock'
        system "rake convert:refresh_stocks RAILS_ENV=#{Rails.env}" #  --trace >> #{Rails.root}/log/rake.log &"
      else
        system "rake convert:refresh_options_funds RAILS_ENV=#{Rails.env}" #  --trace >> #{Rails.root}/log/rake.log &"
      end
    end
    
    totals = Hash.new
    Portfolio.all.each { |p| totals[p.id] = (p.cash + p.total_stocks_value + p.total_options_value).to_f }
    @ordered = Portfolio.find(totals.sort_by { |key, value | -value }.collect { |id, value| id })
    @total_cash = Portfolio.all.sum { |s| s.cash }
    @total_stocks = Portfolio.all.sum { |s| s.total_stocks_value }
    @total_stocks_change = Portfolio.all.sum { |s| s.total_stocks_change_value }
    @total_options = Portfolio.all.sum { |s| s.total_options_value }
    
    @last_update = Stock.where(stock_option: 'Stock').last.updated_at
    
    respond_to do |format|
        format.html
        format.js
    end
    
  end

  # GET /portfolios/1
  # GET /portfolios/1.json
  def show
    stocks = @portfolio.stocks
    @stocks = stocks.collect { |s| [ s.quantity * s.price, s.id ]  }.sort_by { |value, id| -value }.collect { |value, id| Stock.find(id) }
  end

  # GET /portfolios/new
  def new
    @portfolio = Portfolio.new
  end

  # GET /portfolios/1/edit
  def edit
  end

  # POST /portfolios
  # POST /portfolios.json
  def create
    @portfolio = Portfolio.new(portfolio_params)

    respond_to do |format|
      if @portfolio.save
        format.html { redirect_to @portfolio, notice: 'Portfolio was successfully created.' }
        format.json { render :show, status: :created, location: @portfolio }
      else
        format.html { render :new }
        format.json { render json: @portfolio.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /portfolios/1
  # PATCH/PUT /portfolios/1.json
  def update
    respond_to do |format|
      if @portfolio.update(portfolio_params)
        format.html { redirect_to @portfolio, notice: 'Portfolio was successfully updated.' }
        format.json { render :show, status: :ok, location: @portfolio }
      else
        format.html { render :edit }
        format.json { render json: @portfolio.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /portfolios/1
  # DELETE /portfolios/1.json
  def destroy
    @portfolio.destroy
    respond_to do |format|
      format.html { redirect_to portfolios_url, notice: 'Portfolio was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_portfolio
      @portfolio = Portfolio.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def portfolio_params
      params.require(:portfolio).permit(:user_id, :name, :cash)
    end
end
