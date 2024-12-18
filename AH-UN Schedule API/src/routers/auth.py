import os
from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import select
import jwt
from datetime import datetime, timezone, timedelta

from src.database import get_session
from src.middleware.auth import require_auth
from src.types import LoginCredentials
from src.models.user import User, UserRead

SECRET_KEY = os.getenv("JWT_KEY")
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
    session = Depends(get_session),
):
    user = session.exec(
        select(User)
        .where(User.username == credentials.username)
    ).one_or_none()

    if not user:
        raise HTTPException(status_code=401)

    data = {
        "sub": user.username,
        "exp": datetime.now(timezone.utc) + timedelta(minutes=60)
    }

    token = jwt.encode(data, SECRET_KEY, algorithm=ALGORITHM)

    return {
        "token": token
    }
