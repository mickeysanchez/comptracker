class UserMailer < ActionMailer::Base
  default from: "compbuddy@comptracker.com"
  
  def welcome_email(user)
    @user = user  
    mail(to: @user.email, subject: "You made an account!")
  end
  
  def comp_email(user)
    @user = user
    @accounts = @user.accounts
    mail(to: @user.email, subject: "Your daily comp reminders.")
  end
  
end
