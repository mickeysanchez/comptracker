require 'open-uri'
require 'mechanize'
require 'watir-webdriver'
require 'headless'

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
    
    headless = Headless.new
    headless.start
    browser = Watir::Browser.start "http://www.totalrewards.com/e-totalrewards/?"
    @part = browser.title
    browser.close
    headless.destroy
    
    @part = "butt"
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

    respond_to do |format|
      if @user.save
        sign_in @user
        
        UserMailer.welcome_email(@user).deliver
        
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
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
    redirect_to root_url
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
