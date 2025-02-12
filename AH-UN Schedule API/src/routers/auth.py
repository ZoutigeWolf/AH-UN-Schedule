import os
from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
import jwt
import base64
import bcrypt
from datetime import datetime, timezone, timedelta

from src.database import get_session
from src.middleware.auth import require_auth
from src.types import LoginCredentials
from src.models.user import User, UserRead

SECRET_KEY = os.getenv("JWT_KEY") or base64.b64encode(os.urandom(32)).decode("utf-8")
ALGORITHM = os.getenv("JWT_ALGO")

router = APIRouter(
    prefix="/auth",
    tags=["Auth"]
)


@router.get("/me")
async def me(user: User = Depends(require_auth)):
    return UserRead(**user.model_dump())


@router.post("/login")
async def login(
    credentials: LoginCredentials,
    session: Session = Depends(get_session),
):
    user = session.exec(
        select(User)
        .where(User.username == credentials.username)
    ).one_or_none()

    if not user:
        raise HTTPException(status_code=401)

    if not bcrypt.checkpw(credentials.password.encode("utf-8"), user.password_hash):
        raise HTTPException(status_code=401)

    data = {
        "sub": user.username,
        "exp": datetime.now(timezone.utc) + timedelta(minutes=60)
    }

    token = jwt.encode(data, SECRET_KEY, algorithm=ALGORITHM)

    return {
        "token": token
    }
