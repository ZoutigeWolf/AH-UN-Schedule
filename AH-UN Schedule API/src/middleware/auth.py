import os
from fastapi import HTTPException, Depends
import jwt
from sqlmodel import Session, select
from starlette.requests import Request

from src.database import get_session
from src.models.user import User

SECRET_KEY = os.getenv("JWT_KEY")
ALGORITHM = os.getenv("JWT_ALGO") or "HS256"

def require_auth(request: Request, session: Session = Depends(get_session)):
    if "Authorization" not in request.headers:
        raise HTTPException(status_code=401)

    auth_header = request.headers["Authorization"]

    token = auth_header.removeprefix("Bearer ")

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])

    except:
        raise HTTPException(status_code=401)

    username: str = payload.get("sub")

    user = session.exec(
        select(User).where(User.username == username)
    ).one_or_none()

    if not user:
        raise HTTPException(status_code=401)

    return user
