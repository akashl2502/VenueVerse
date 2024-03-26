from flask import Flask, request, jsonify
from firebase_admin import credentials, initialize_app, messaging
import json
import os
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

app = Flask(__name__)
sender_email = "venueverse2023@gmail.com"
sender_password = "vlik vlzx gymu ejxl"
# Enable CORS
@app.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', '*')
    response.headers.add('Access-Control-Allow-Methods', '*')
    return response
cred = credentials.Certificate("mysite/Servicekey.json")
# cred = credentials.Certificate("./Servicekey.json")
initialize_app(cred)


class PushNotificationRequest:
    def __init__(self, registration_token, title, body):
        self.registration_token = registration_token
        self.title = title
        self.body = body
@app.route('/')
def get_current_directory():
    current_directory = os.getcwd()
    return f"The current directory is: {current_directory}"
@app.route("/send_push_notification/", methods=["POST"])
def send_push_notification():
    try:
        request_data = request.get_json()

        # Send the message
        if request_data["state"] == 0 and request_data["email"]:
            subject = "Venue Verse - New booking Request"
            body = request_data["body"]
            registration_token = request_data["registration_token"]
            title = request_data["title"]
            body = request_data["body"]
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body
                ),
                token=registration_token
            )
            response = messaging.send(message)


        elif request_data["state"] == 1 and request_data["email"]:
            subject = "Venue Verse - Request Status"
            body = request_data["body"]
            registration_token = request_data["registration_token"]
            title = str(request_data["title"])  # Convert title to string
            body = request_data["body"]
            for data in registration_token:
                message = messaging.Message(
                    notification=messaging.Notification(
                        title=title,
                        body=body
                    ),
                    token=data
                )
                response = messaging.send(message)


        if request_data["email"]:
            # for sep_email in request_data["email"]:
            message = MIMEMultipart()
            message["From"] = sender_email
            message["To"] = ', '.join(request_data["email"])
            message["Subject"] = subject
            message.attach(MIMEText(body, "plain"))
            with smtplib.SMTP("smtp.gmail.com", 587) as server:
                server.starttls()
                server.login(sender_email, sender_password)
                server.sendmail(sender_email, request_data["email"], message.as_string())
        return jsonify({"message_id": response}), 200

    except Exception as e:
        return str(e), 500


