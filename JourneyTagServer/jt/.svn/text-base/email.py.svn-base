from google.appengine.api import mail

def sendMessage(fromEmail, message):
    subject = 'JourneyTag Support Request'
    body = 'From: %s\n\n' % fromEmail
    body += 'Message:\n'
    body += message[0:5000]
    body += '\n\nNOTE: message was truncated to 5000 characters'
    mail.send_mail('support@journeytag.com','support@journeytag.com', subject, body)