# Email notifications.
class Notify < ActionMailer::Base
  
  # Notify a user that their email forwarding address has been changed.
  def mail_forward_update(user, updater, old)
    @user = user
    @updater = updater
    @old = old
    mail(:to => user.mail, :cc => (old ? [ old ] : []) + [ default_params[:reply_to] ])
  end
  
  # Notify a user that their password has been reset.
  def password_reset(user, resetter, temporary)
    @user = user
    @resetter = resetter
    @temporary = temporary
    mail(:to => user.mail, :cc => default_params[:reply_to])
  end
  
end
