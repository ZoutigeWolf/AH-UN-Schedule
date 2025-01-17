from fastapi import APIRouter, Depends, HTTPException, Response
from sqlmodel import Session, select

from src.database import get_session
from src.middleware.auth import require_auth
from src.models.user import User, UserRead, UserUpdate
from src.models.user_device import UserDevice
from src.types import DeviceInfo


router = APIRouter(
    prefix="/users",
    tags=["Users"]
)

@router.get("", response_model=list[UserRead])
async def get_users(
    session: Session = Depends(get_session),
    _: User = Depends(require_auth)
):
    users = session.exec(
        select(User)
    ).all()

    return [u.serialize() for u in users]


@router.get("/{username}", response_model=UserRead)
async def get_user(
    username: str,
    session: Session = Depends(get_session),
    _: User = Depends(require_auth)
):
    user = session.exec(
        select(User).where(User.username == username)
    ).one_or_none()

    if not user:
        return HTTPException(status_code=404)

    return user.serialize()


@router.patch("/{username}")
async def edit_user(
    username: str,
    data: UserUpdate,
    session: Session = Depends(get_session),
    auth_user: User = Depends(require_auth)
):
    if not auth_user.admin:
        return HTTPException(status_code=403)

    user = session.exec(
        select(User).where(User.username == username)
    ).one_or_none()

    if not user:
        return HTTPException(status_code=404)

    if data.admin is not None:
        user.admin = data.admin

    u = user.serialize()

    session.commit()

    return u


@router.delete("/{username}")
async def delete_user(
    username: str,
    session: Session = Depends(get_session),
    auth_user: User = Depends(require_auth)
):
    if not auth_user.admin:
        return HTTPException(status_code=403)

    user = session.exec(
        select(User).where(User.username == username)
    ).one_or_none()

    if not user:
        return HTTPException(status_code=404)

    session.delete(user)

    return Response(status_code=200)


@router.post("/{username}/devices")
async def add_device(
    username: str,
    info: DeviceInfo,
    session: Session = Depends(get_session),
    user: User = Depends(require_auth),
):
    if username != user.username:
        raise HTTPException(status_code=403)

    device = session.exec(
        select(UserDevice)
        .where(
            UserDevice.username == user.username,
            UserDevice.device == info.device
        )
    ).one_or_none()

    if device:
        raise HTTPException(status_code=409)

    device = UserDevice(
        username=user.username,
        device=info.device
    )

    session.add(device)

    return Response(status_code=201)
