from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from firebase_admin import credentials, initialize_app, messaging

app = FastAPI()

# Initialize Firebase Admin SDK
cred = credentials.Certificate("path/to/serviceAccountKey.json")
initialize_app(cred)

# Create a Pydantic model for the request body
class PushNotificationRequest(BaseModel):
    registration_token: str
    title: str
    body: str

# Endpoint to send push notification
@app.post("/send_push_notification/")
async def send_push_notification(notification_request: PushNotificationRequest):
    try:
        # Prepare the notification message
        message = messaging.Message(
            notification=messaging.Notification(
                title=notification_request.title,
                body=notification_request.body
            ),
            token=notification_request.registration_token
        )

        # Send the message
        response = messaging.send(message)

        return {"message_id": response}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Run the FastAPI application
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
