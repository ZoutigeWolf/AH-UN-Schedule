from fastapi import APIRouter, Depends, HTTPException, Response
from sqlmodel import Session, select
import bcrypt

from src.database import get_session
from src.middleware.auth import require_auth
from src.models.user import User, UserRead, UserUpdate, UserUpdatePassword
from src.models.user_device import UserDevice
from src.models.user_settings import UserSettings, UserSettingsUpdate
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


@router.put("/{username}/password")
async def edit_user_password(
    username: str,
    data: UserUpdatePassword,
    session: Session = Depends(get_session),
    auth_user: User = Depends(require_auth)
):
    user = session.exec(
        select(User).where(User.username == username)
    ).one_or_none()

    if not user:
        return HTTPException(status_code=404)

    if not auth_user.admin and user.username != auth_user.username:
        return HTTPException(status_code=403)

    if not bcrypt.checkpw(data.auth_password.encode("utf-8"), auth_user.password_hash):
        raise HTTPException(status_code=403)

    user.password_hash = bcrypt.hashpw(data.new_password.encode("utf-8"), bcrypt.gensalt())

    session.commit()

    return Response(status_code=200)


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
    session.commit()

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
    session.commit()

    return Response(status_code=201)


@router.delete("/{username}/devices/{device_token}")
async def remove_device(
    username: str,
    device_token: str,
    session: Session = Depends(get_session),
    user: User = Depends(require_auth),
):
    if username != user.username:
        raise HTTPException(status_code=403)

    device = session.exec(
        select(UserDevice)
        .where(
            UserDevice.username == user.username,
            UserDevice.device == device_token
        )
    ).one_or_none()

    if not device:
        raise HTTPException(status_code=404)

    session.delete(device)
    session.commit()

    return Response(status_code=200)


@router.get("/{username}/settings")
async def get_user_settings(
    username: str,
    session: Session = Depends(get_session),
    user: User = Depends(require_auth),
):
    if username != user.username:
        raise HTTPException(status_code=403)

    settings = session.exec(
        select(UserSettings)
        .where(UserSettings.username == user.username)
    ).one_or_none()

    if not settings:
        settings = UserSettings(username=user.username)
        session.add(settings)
        session.commit()

    return settings


@router.patch("/{username}/settings")
async def edit_user_settings(
    username: str,
    data: UserSettingsUpdate,
    session: Session = Depends(get_session),
    user: User = Depends(require_auth),
):
    if username != user.username:
        raise HTTPException(status_code=403)

    settings = session.exec(
        select(UserSettings)
        .where(UserSettings.username == user.username)
    ).one_or_none()

    if not settings:
        settings = UserSettings(username=user.username)
        session.add(settings)

    if data.wage is not None:
        settings.wage = data.wage

    if data.calendar_event_title is not None:
        settings.calendar_event_title = data.calendar_event_title

    if data.notifications_new_schedule is not None:
        settings.notifications_new_schedule = data.notifications_new_schedule

    if data.notifications_work_reminder is not None:
        settings.notifications_work_reminder = data.notifications_work_reminder

    if data.notifications_work_reminder_time is not None:
        settings.notifications_work_reminder_time = data.notifications_work_reminder_time

    session.commit()

    return Response(status_code=200)
