class PortfoliosController < ApplicationController
  before_action :set_portfolio, only: [:show, :edit, :update, :destroy]

  def poll_check
    ironcache = IronCache::Client.new
    cache = ironcache.cache("my_cache")
    @poll_request_time = cache.get("poll_request_time").value
    @data = Hash.new
    @data['poll_request'] = cache.get("poll_request").value
      respond_to do |format|
          format.js
      end

  end
  
  def index
    heroku = ENV['RACK_ENV'] != 'development'

    if request.xhr?
      if !heroku
        system "rake convert:refresh_all RAILS_ENV=#{Rails.env}" #  --trace >> #{Rails.root}/log/rake.log &"
      else
        
#        system "rake convert:refresh_all" run on Heroku
                
       @ironcache = IronCache::Client.new
       @cache = @ironcache.cache("my_cache")
       if @cache.get("poll_request").value == 'false'
         @cache.put("poll_request", 'true')
       end
      end 
      
    end
    @group_names = ['All Portfolios'] + Group.all.collect { |g| g.name }
    group_ids = [ nil ] + Group.all.collect { |g| g.id }
    @all_data = group_ids.collect { |i| Portfolio.table_data(i) }
#    @all_data = [ Portfolio.table_data(nil),
#             Portfolio.table_data(1),
#             Portfolio.table_data(2),
#             Portfolio.table_data(3) ]
             
     if heroku
       @ironcache = IronCache::Client.new
       @cache = @ironcache.cache("my_cache")
       @poll_request_time = Time.parse(@cache.get("poll_request_time").value)
     else
       @poll_request_time = @all_data[0][5]      
     end
    
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
