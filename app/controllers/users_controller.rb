require 'watir-webdriver'
require 'date'
require 'time'

class UsersController < ApplicationController
  before_action :signed_in_user, only: :show
  before_action :correct_user, only: :show
  
  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])
    @accounts = @user.accounts
    
    # if @accounts.count > 0
    # 
    #   # scrape Total Rewards if the user has entered a Total Rewards Account
    #   if @accounts.find_by(:type_of_account => "Total Rewards")
    #     get_total_rewards_comps
    #   end
    #   
    #   # scrape Borgata Rewards
    #   if @accounts.find_by(:type_of_account => "Borgata Rewards")
    #     get_borgata_comps
    #   end
    # end
    
  end

  def get_total_rewards_comps
    @user = User.find(params[:id])
    @accounts = @user.accounts
    # set up and initialize Watir and Phantomjs in a way that works for the Total Rewards Page.
    capabilities = Selenium::WebDriver::Remote::Capabilities.phantomjs("phantomjs.page.settings.userAgent" => "Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/28.0.1468.0 Safari/537.36")
    driver = Selenium::WebDriver.for :phantomjs, :desired_capabilities => capabilities
    switches = ['--ignore-ssl-errors=yes']
    browser = ::Watir::Browser.new driver 

    
    total_rewards_account = @accounts.find_by(:type_of_account => "Total Rewards")

    # get to offers page
    browser.goto  "http://www.totalrewards.com/e-totalrewards/?"
    browser.input(:id => "username").to_subtype.set(total_rewards_account.username)
    browser.input(:id => "pin").to_subtype.set(total_rewards_account.password_digest)
    browser.button(:value => "Sign In").click
    browser.link(:href => "/TotalRewards/Offers.do?", :text => "Your Offers").click
    
    # scrape offers
    browser.frame(:id => "offerDisplayMod_iframe").wait_until_present
    offers = browser.frame(:id => "offerDisplayMod_iframe").divs(:class => "pItem")
    @total_rewards_comps = {}
    offers.each do |offer|
      if offer.span(:class => "lblSubjectOld").exists?
        name = offer.span(:class => "lblSubjectOld").text
      else
        name = offer.span(:class => "lblSub").text
      end
      date = offer.div(:class => "expwidth").text
      
      @total_rewards_comps[name] = date
    end
    
    @total_rewards_comps.each do |key, value|
      value.chomp!
      expiration = value[-10..-1]
      expiration = DateTime.strptime(expiration, '%m/%d/%Y')
      today = Date.today
      @total_rewards_comps[key] = expiration.mjd - today.mjd
    end
    
    browser.close
    
    respond_to do |format|
      format.js
    end
  end
  
  def get_borgata_comps
    @user = User.find(params[:id])
    @accounts = @user.accounts
    
    # Check and wait until watir / phantomjs is done with other requests
    browsers = []
    ObjectSpace.each_object(Watir::Browser) {|b| browsers << b}
    p browsers
    p browsers.any? {|b| b.exists?}
    Watir::Wait.until { (browsers.any? {|b| b.exists?}) == false }
    
    # set up and initialize Watir and Phantomjs in a way that works for the Borgata page.
    switches = ['--ignore-ssl-errors=yes']
    browser = Watir::Browser.new :phantomjs, :args => switches
    
    # get to offers page
    borgata_account = @accounts.find_by(:type_of_account => "Borgata Rewards")
    browser.goto "https://www.theborgata.com/casino/mbr"
    browser.input(:id => "borgataMainContentWrapped_content_0_ctlLoginForm_txtEmailAddressOrAccountNumber").to_subtype.set(borgata_account.username)
    browser.input(:id => "borgataMainContentWrapped_content_0_ctlLoginForm_txtPassword").to_subtype.set(borgata_account.password_digest)
    browser.link(:id => "borgataMainContentWrapped_content_0_ctlLoginForm_btnLogin").click
    
    # scrape comps
    comps = browser.table(:class => "data-list-table offers").tbody.trs
    @borgata_comps = {}
    
    comps.each do |comp|
      name = comp.td(:class => "offer-name").text
      date = comp.td(:class => "offer-date").text
      
      date.chomp!
      expiration = date[-8..-1]
      expiration.lstrip!
      expiration = Date.strptime(expiration, '%m.%d.%y')
      
      today = Date.today
      
      @borgata_comps[name] = expiration.mjd - today.mjd
    end
  
    browser.close 
    
    respond_to do |format|
      format.js
    end
  end
  

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    if @user.save
      UserMailer.welcome_email(@user).deliver
      
      sign_in @user
      
      redirect_to @user, notice: 'User was successfully created.'
    else
      render 'new'
    end
    
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update_attributes(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted."
    cookies.delete(:remember_token)
    redirect_to root_url
  end
  
  def send_comps_email
    @user = User.find(params[:id])
    UserMailer.comp_email(@user).deliver
    redirect_to @user
  end
  
  private

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end
    
    def correct_user
      @user = User.find(params[:id])
      unless current_user?(@user)
        redirect_to signin_url
      end
    end
    
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
