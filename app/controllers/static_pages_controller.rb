class StaticPagesController < ApplicationController
  def home
    if signed_in?
      flash[:error] = "Already signed in. Sign out first to sign in as a different user."
      redirect_to(current_user)
    end
  end

  def help
  end
end
