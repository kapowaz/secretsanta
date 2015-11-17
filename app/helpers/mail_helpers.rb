class SecretSanta
  class MailHelpers
    def self.mail_with_template(template, recipient, subject, locals={})
      Pony.mail({
        to:          recipient,
        from:        "Secret Santa <secretsanta@grainneandben.uk>",
        subject:     subject,
        html_body:   SecretSanta::ViewHelpers.erb("email/#{template}".to_sym, locals),
        via:         :smtp,
        via_options: YAML.load(File.new('./config/smtp.yml'))
      })
    end
  end
end
