from google.appengine.api import mail

def emailPassword(toEmail, username, password):
    subject = 'JourneyTag: Password Reset Message'
    body = 'You have requested to reset your password.  Your new login information is in this email.\n\n'
    body += 'Username:  %s \n' % username
    body += 'New password:  %s\n\n' % password
    body += 'Please login to change your password back to something you can remember.'
    mail.send_mail('support@journeytag.com', toEmail, subject, body)

def emailUsernames(toEmail, usernames):
    subject = 'JourneyTag: Username Request'
    body = 'Here are a list of usernames registered with your email address on your device.\n'
    for name in usernames:
        body += '-%s \n' % name
        
    mail.send_mail('support@journeytag.com', toEmail, subject, body)

def emailTransferCode(toEmail, token):
    subject = 'JourneyTag: Transfer Code Request'
    body = 'You have requested to transfer your account to another device. \n\n Here is your transfer code: %s' % token
    body += '\n\nTo finish this request do the following:'
    body += '\n1) Launch the app on the device you want to transfer to.'
    body += '\n2) Go to the "New Account" screen and press the "Transfer" button.'
    body += '\n3) Enter your credentials'
    body += '\n3) Enter this transfer code: %s' % token
    body += '\n\nRemember: This is a one time operation.  You cannot move your account back to a previous device.'
    body += '\nIf you need to move to a prevous device, go to the website and contact support'
    mail.send_mail('support@journeytag.com', toEmail, subject, body)