class UserMailerPreview < ActionMailer::Preview
  def confirmation
    user = User.first
    # This is how you pass value to params[:user] inside mailer definition!
    UserMailer.with(user: user).confirmation
  end
end