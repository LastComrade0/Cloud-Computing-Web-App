from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()


app = FastAPI()

origins = ["*"]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ContactForm(BaseModel):
    name: str
    email: EmailStr
    message: str

@app.get("/healthz")
def healthz():
    return {"ok": True}

@app.post("/contact")
async def contact(contact_data: ContactForm):
    try:
        # Email configuration
        smtp_server = "smtp.gmail.com"
        smtp_port = 587
        sender_email = os.getenv("EMAIL_USER")
        sender_password = os.getenv("EMAIL_PASSWORD")
        recipient_email = "ychen355@dons.usfca.edu"
        
        # Debug: Print the credentials being used (remove this after testing)
        '''
        print(f"DEBUG - EMAIL_USER from env: {os.getenv('EMAIL_USER')}")
        print(f"DEBUG - EMAIL_PASSWORD from env: {os.getenv('EMAIL_PASSWORD')}")
        print(f"DEBUG - Using email: {sender_email}")
        print(f"DEBUG - Using password: {sender_password[:4]}..." if sender_password else "DEBUG - No password found")
        '''
        
        # Create message
        msg = MIMEMultipart()
        msg['From'] = sender_email
        msg['To'] = recipient_email
        msg['Subject'] = f"Portfolio Contact Form - {contact_data.name}"
        
        # Email body
        body = f"""
        New contact form submission:
        
        Name: {contact_data.name}
        Email: {contact_data.email}
        Message: {contact_data.message}
        """
        
        msg.attach(MIMEText(body, 'plain'))
        
        # Send email
        server = smtplib.SMTP(smtp_server, smtp_port)
        server.starttls()
        server.login(sender_email, sender_password)
        text = msg.as_string()
        server.sendmail(sender_email, recipient_email, text)
        server.quit()
        
        print(f"Contact form received and email sent: {contact_data.name} - {contact_data.email}")
        return {"status": "success", "message": "Email sent successfully"}
        
    except Exception as e:
        print(f"Error sending email: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to send email")
