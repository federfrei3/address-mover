class UserMailer < ApplicationMailer
    def confirmation
      @user = params[:user] # Instance variable => available in view
      mail(to: @user.email, subject: 'Your Request is sent')
      # This will render a view in `app/views/user_mailer`!
    end
  end