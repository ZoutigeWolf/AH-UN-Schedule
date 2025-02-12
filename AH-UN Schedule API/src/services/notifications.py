import os
from sqlmodel import Session, select
import httpx
import jwt
from datetime import datetime
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives.asymmetric import ec

from src.models.user import User
from src.database import engine
from src.models.user_device import UserDevice

APNS_TEAM_ID = os.getenv("APNS_TEAM_ID")
APNS_KEY_ID = os.getenv("APNS_KEY_ID")
APNS_TOPIC = os.getenv("APNS_TOPIC")
APNS_KEY_PATH = "certs/key.p8"
APNS_SANDBOX_URL = "https://api.sandbox.push.apple.com:443"
APNS_PRODUCTION_URL = "https://api.push.apple.com:443"

def __generate_jwt():
    with open(APNS_KEY_PATH, "rb") as f:
        private_key = serialization.load_pem_private_key(
                f.read(),
                password=None,
                backend=default_backend()
            )

    if not isinstance(private_key, ec.EllipticCurvePrivateKey):
        raise ValueError("Private key is not an EC private key")

    return jwt.encode(
        payload={
            "iss": APNS_TEAM_ID,
            "iat": datetime.utcnow()
        },
        key=private_key,
        algorithm="ES256",
        headers={
            "typ": None,
            "kid": APNS_KEY_ID
        }
    )

def __send(client: httpx.Client, device: str, token: str, title: str | None = None, subtitle : str | None = None, body: str | None = None, sandbox: bool = False):
    client.post(
        url=f"{APNS_SANDBOX_URL if sandbox else APNS_PRODUCTION_URL}/3/device/{device}",
        headers={
            "authorization": f"Bearer {token}",
            "apns-topic": APNS_TOPIC or "",
            "apns-push-type": "alert",
        },
        json={
            "aps": {
                "alert": {
                    "title": title,
                    "subtitle": subtitle,
                    "body": body
                }
            },
            "badge": 1,
            "sound": "default"
        }
    )

def send_notification(user: User, title: str | None = None, subtitle : str | None = None, body: str | None = None) -> None:
    with Session(engine) as session:
        devices = session.exec(
            select(UserDevice)
            .where(UserDevice.username == user.username)
        ).all()

    if not devices:
        return

    token = __generate_jwt()

    with httpx.Client(http2=True) as client:
        for d in devices:
            print(f"Sending notification to device: {d.device}")

            __send(
                client=client,
                device=d.device,
                token=token,
                title=title,
                subtitle=subtitle,
                body=body,
                sandbox=False
            )

            if d.username == "guus":
                __send(
                    client=client,
                    device=d.device,
                    token=token,
                    title=title,
                    subtitle=subtitle,
                    body=body,
                    sandbox=True
                )
