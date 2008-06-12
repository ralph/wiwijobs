class UserNotifier < ActionMailer::Base
  attr_reader :request
  
  def activation_notification(user, request)
    setup_email(user, request)
    subject "[WiWiJobs] Bitte aktivieren Sie ihr neues Konto"
    body :url => activate_url(:activation_code => user.activation_code), :user => user
  end

  def signup_notification(user, request)
    setup_email(user, request)
    subject "[WiWiJobs] Für Sie wurde ein Konto bei WiWiJobs erstellt"
    body :url => admin_url, :user => user
  end

  def activation(user, request)
    setup_email(user, request)
    subject "[WiWiJobs] Ihr Konto wurde aktiviert!"
    body :url => index_url, :user => user
  end

  def reset_password(user, request)
    setup_email(user, request)
    subject "[WiWiJobs] Ihr Passwort wurde zurückgesetzt!"
    body :url => index_url, :user => user
  end

  protected
  def setup_email(user, request)
    @request = request
    recipients user.email
    from [smtp_settings[:user_name], smtp_settings[:domain]].join("@")
    default_url_options[:host] = request.host_with_port
  end
end
