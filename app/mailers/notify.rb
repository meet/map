# Email notifications.
class Notify < ActionMailer::Base
  
  # Notify a user that their email forwarding address has been changed.
  def mail_forward_update(user, updater, old)
    @user = user
    @updater = updater
    @old = old
    mail(:to => user.mail, :cc => (old ? [ old ] : []) + [ default_params[:reply_to] ])
  end

  # Notify a user that their mail inbox has been changes.
  def mail_destination_inbox_update(user, updater, mail_forward)
    @user = user
    @updater = updater
    @mail_forward = mail_forward
    mail(:to => user.mail_forward, :cc => [mail_forward] + [ default_params[:reply_to] ])
  end

  # Notify a user that their password has been reset.
  def password_reset(user, resetter, temporary)
    @user = user
    @resetter = resetter
    @temporary = temporary
    mail(:to => user.mail, :cc => default_params[:reply_to])
  end
  
  # Notify a potential user that they can create an account.
  def user_request(user)
    @user = user
    mail(:to => user.mail_forward, :cc => default_params[:reply_to])
  end
  
  # Notify parties that a new account has been created.
  def user_created(user, requester)
    @user = user
    @requester = requester
    mail(:to => [ user.mail_forward, requester.mail ], :cc => default_params[:reply_to])
  end
  
end
