class AccountsController < ApplicationController
  before_action :set_account, only: [:show, :edit, :update, :destroy]
  before_action :signed_in_user
  
  include AccountsHelper

  # GET /accounts
  # GET /accounts.json
  def index
    @accounts = Account.all
  end

  # GET /accounts/1
  # GET /accounts/1.json
  def show
  end

  # GET /accounts/new
  def new
    @account = Account.new
  end

  # GET /accounts/1/edit
  def edit
  end

  # POST /accounts
  # POST /accounts.json
  def create
    @account = current_user.accounts.build(account_params)

      if @account.save
        if @account.type_of_account == "Total Rewards"
          get_total_rewards_comps
        end
        redirect_to current_user, notice: 'Account was successfully created.'
      else
        render action: 'new'
      end

  end

  # PATCH/PUT /accounts/1
  # PATCH/PUT /accounts/1.json
  def update
    respond_to do |format|
      if @account.update(account_params)
        format.html { redirect_to @account, notice: 'Account was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @account.destroy
    respond_to do |format|
      format.html { redirect_to current_user }
      format.json { head :no_content }
    end
  end
  
  def get_total_rewards_comps
    browser = total_rewards_browser

    total_rewards_account = current_user.accounts.find_by(:type_of_account => "Total Rewards")
    navigate_to_total_rewards_offers(browser)
   
    @total_rewards_comps = scrape_total_rewards(browser)
    
    prepare_total_rewards_comps(@total_rewards_comps)
       
    browser.close
  
    respond_to do |format|
      format.html
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def account_params
      params.require(:account).permit(:type_of_account, :username, :password_digest)
    end
end
