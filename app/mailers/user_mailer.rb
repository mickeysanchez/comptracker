class UserMailer < ActionMailer::Base
  default from: "app18973717@heroku.com"
  
  def welcome_email(user)
    @user = user  
    mail(to: @user.email, subject: "You made an account!")
  end
  
end
