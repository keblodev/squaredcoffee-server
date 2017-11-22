
class Mailer
    def self.send_verify(email, origin, verify_email_token, remove_email_token)
        AwsMailer.send_email({
            receiver: email,
            subject: 'Email Verification',
            body_text: [
              'Hi there and thank you for signing up with us.',
              'Please follow the verification link bellow:',
              "#{origin}/auth/email/validate?token=#{verify_email_token}",
              'If you did not create an account with us, ',
              'please click the following link to prevent unauthorized',
              'use of your email address.',
              "#{origin}/auth/email/invalidate?token=#{remove_email_token}",
            ].join("\n\n")
        })
    end


    def self.send_email_verify_for_exisiting_user(email, origin, verify_email_token)
        AwsMailer.send_email({
            receiver: email,
            subject: 'Email Verification',
            body_text: [
              'Please follow the verification link bellow:',
              "#{origin}/auth/email/validate?token=#{verify_email_token}",
            ].join("\n\n")
        })
    end

    def self.send_password_reset(email, origin, reset_password_token)
        AwsMailer.send_email({
            receiver: email,
            subject: 'Password Reset',
            body_text: [
                'You are receiving this because ',
                'you have requested to reset the password for your account.',
                'Please click on the following link:',
                "#{origin}/user/password/reset?token=#{reset_password_token}",
                'If you did not request this,',
                'please ignore this email and your password will remain unchanged.',
            ].join("\n\n")
        })
    end
end