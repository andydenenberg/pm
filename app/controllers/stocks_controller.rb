class StocksController < ApplicationController
  before_action :set_stock, only: [:show, :edit, :update, :destroy]

  # GET /stocks
  # GET /stocks.json
  def index
    
    stocks_funds = Stock.where(stock_option: 'Stock').or(Stock.where(stock_option: 'Fund'))
    options = Stock.where(stock_option: 'Call Option').or(Stock.where(stock_option: 'Put Option'))
    
    symbols = stocks_funds.distinct.pluck(:symbol)
    values = symbols.collect { |sym| [ sym, stocks_funds.where(symbol: sym).sum(0) { |data| (data.quantity * data.price).to_f }] }

    values = values.sort_by { |sym, value| -value }
    @total_value = values.sum(0) { |sym, value| value }.to_f
    
    @stocks_up = values.collect { |sym, value| [ sym, 
                        stocks_funds.where(symbol: sym).sum(0) { |data| data.quantity.to_f },
                        value,
                        (stocks_funds.where(symbol: sym).first.change * stocks_funds.where(symbol: sym).sum(0) { |data| data.quantity } ).to_f,
                        stocks_funds.where(symbol: sym).collect { |stock| stock.portfolio_id }.collect { |id| Portfolio.find(id).name }.join(', '),
                        stocks_funds.where(symbol: sym).first.price,
                        stocks_funds.where(symbol: sym).first.change
                     ] }.sort_by {|data| -data[3] }[0..5]

   @stocks_down = values.collect { |sym, value| [ sym, 
                       stocks_funds.where(symbol: sym).sum(0) { |data| data.quantity.to_f },
                       value,
                       (stocks_funds.where(symbol: sym).first.change * stocks_funds.where(symbol: sym).sum(0) { |data| data.quantity } ).to_f,
                       stocks_funds.where(symbol: sym).collect { |stock| stock.portfolio_id }.collect { |id| Portfolio.find(id).name }.join(', '),
                       stocks_funds.where(symbol: sym).first.price,
                       stocks_funds.where(symbol: sym).first.change
                    ] }.sort_by {|data| data[3] }[0..5]
    
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
end
