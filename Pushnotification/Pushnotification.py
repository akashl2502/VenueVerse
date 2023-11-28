from flask import Flask, request, jsonify
from firebase_admin import credentials, initialize_app, messaging

app = Flask(__name__)

# Enable CORS
@app.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', '*')
    response.headers.add('Access-Control-Allow-Methods', '*')
    return response

cred = credentials.Certificate("Servicekey.json")
initialize_app(cred)

class PushNotificationRequest:
    def __init__(self, registration_token, title, body):
        self.registration_token = registration_token
        self.title = title
        self.body = body

@app.route("/send_push_notification/", methods=["POST"])
def send_push_notification():
    try:
        request_data = request.get_json()
        notification_request = PushNotificationRequest(
            registration_token=request_data["registration_token"],
            title=request_data["title"],
            body=request_data["body"]
        )

        message = messaging.Message(
            notification=messaging.Notification(
                title=notification_request.title,
                body=notification_request.body
            ),
            token=notification_request.registration_token
        )

        # Send the message
        response = messaging.send(message)

        return jsonify({"message_id": response}), 200

    except Exception as e:
        return str(e), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
