class StocksController < ApplicationController
  before_action :set_stock, only: [:show, :edit, :update, :destroy]

  helper_method :sort_column, :sort_direction, :select_tab

  def dividends
    @dates = Stock.all_dividend_dates
#    portfolios = Portfolio.where(group_id: Group.where(name: 'Personel Portfolios').last.id )
    portfolios = Portfolio.all.collect { |p| p.id }
    @divs = Stock.monthly_dividends(portfolios)
    @annual_divs = Stock.annual_dividends(@divs)
    @total_monthly = Stock.total_monthly_dividends(@divs)
    @funds = Stock.where(stock_option: 'Fund')
  end
  
  # GET /stocks
  # GET /stocks.json
  def index    
    @portfolios = ["All Portfolios"] + Group.all.collect { |group| group.name } + Portfolio.all.collect { |p| p.name }    

    @portfolio_name = params[:portfolio_name] ||= 'All Portfolios'
    
    translate = { symbol: 0, value: 2, change: 3, dividends: 7 }
    column = translate[sort_column.to_sym]
    
    stocks = Stock.where(portfolio_id: Lib.translate_groupids(@portfolio_name).first )
    stocks_funds = stocks.where(stock_option: 'Stock').or(stocks.where(stock_option: 'Fund'))
    
    symbols = stocks_funds.distinct.pluck(:symbol)
    values = symbols.collect { |sym| [ sym, stocks_funds.where(symbol: sym).sum(0) { |data| (data.quantity * data.price).to_f }] }
    @total_value = values.sum(0) { |sym, value| value }.to_f
    change = symbols.collect { |sym| [ sym, stocks_funds.where(symbol: sym).sum(0) { |data| (data.quantity * data.change).to_f }] }
    @total_change = change.sum(0) { |sym, value| value }.to_f
    
    @stocks = values.collect { |sym, value| [ sym, 
        stocks_funds.where(symbol: sym).sum(0) { |data| data.quantity.to_f },
        value,
        (stocks_funds.where(symbol: sym).first.change * stocks_funds.where(symbol: sym).sum(0) { |data| data.quantity } ).to_f,
        stocks_funds.where(symbol: sym).collect { |stock| stock.portfolio_id }.collect { |id| Portfolio.find(id).name }.join(', '),
        stocks_funds.where(symbol: sym).first.price,
        stocks_funds.where(symbol: sym).first.change,
        stocks_funds.where(symbol: sym).sum(0) { |data| (data.quantity * data.daily_dividend).to_f }, # dividends
        stocks_funds.where(symbol: sym).collect { |s| #portfolios
            [ Portfolio.find(s.portfolio_id).name, s.quantity ] }.sort_by { |sym, quantity| -quantity }.collect { |sym, quantity| 
              "#{sym}: #{quantity.round.to_s.split(/(?=(?:...)*$)/).join(',')}"}.to_s.gsub('"','').gsub('[','').gsub(']',''),
        stocks_funds.where(symbol: sym).first.daily_dividend.to_f, # dividend / share
         
#     ] }.sort_by {|data| sort_direction == 'asc' ? -data[column] : data[column] }
      ] }.sort { |x,y| sort_direction == 'asc' ? y[column] <=> x[column] : x[column] <=> y[column] } 
      
                         
     dividends = symbols.collect { |sym| [ sym, stocks_funds.where(symbol: sym).sum(0) { |data| (data.quantity * data.daily_dividend).to_f }] }
     @dividends = dividends.select { |s,d| d > 0 }.sort_by { |sym, dividend| -dividend }
    
     respond_to do |format|
         format.html
         format.js
     end
     
  end

  # GET /stocks/1
  # GET /stocks/1.json
  def show
  end

  # GET /stocks/new
  def new
    @stock = Stock.new
  end

  # GET /stocks/1/edit
  def edit
  end

  # POST /stocks
  # POST /stocks.json
  def create
    @stock = Stock.new(stock_params)

    respond_to do |format|
      if @stock.save
        format.html { redirect_to @stock, notice: 'Stock was successfully created.' }
        format.json { render :show, status: :created, location: @stock }
      else
        format.html { render :new }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stocks/1
  # PATCH/PUT /stocks/1.json
  def update
    respond_to do |format|
      if @stock.update(stock_params)
        format.html { redirect_to @stock, notice: 'Stock was successfully updated.' }
        format.json { render :show, status: :ok, location: @stock }
      else
        format.html { render :edit }
        format.json { render json: @stock.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stocks/1
  # DELETE /stocks/1.json
  def destroy
    @stock.destroy
    respond_to do |format|
      format.html { redirect_to stocks_url, notice: 'Stock was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stock
      @stock = Stock.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stock_params
      params.require(:stock).permit(:portfolio_id, :title, :body, :purchase_price, :quantity, :symbol, :name, :portfolio_id, :purchase_date, :strike, :expiration_date, :stock_option)
    end

    def sort_column
#      Stock.column_names.include?(params[:sort]) ? params[:sort] : "value"
      params[:sort] ||= 'dividends'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
    
end
