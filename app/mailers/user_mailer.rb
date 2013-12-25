class UserMailer < ActionMailer::Base
  default from: "compbuddy@comptracker.com"
  
  def welcome_email(user)
    @user = user  
    mail(to: @user.email, subject: "You made an account!")
  end
  
end
