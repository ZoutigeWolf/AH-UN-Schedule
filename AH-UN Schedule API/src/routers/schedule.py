from fastapi import APIRouter, BackgroundTasks, Depends, HTTPException, Response
from sqlmodel import Session, extract, select
import base64
from ics import Calendar, Event
from datetime import datetime, time
import textwrap
import pytz

from src.database import get_session
from src.middleware.auth import require_auth
from src.models.shift import Shift, ShiftRead, ShiftUpdate
from src.models.user import User
from src.models.user_settings import UserSettings
from src.services.extract import parse_schedule
from src.types import ImageData

router = APIRouter(
    prefix="/schedule",
    tags=["Schedule"]
)

@router.get("/week/{year}/{week}", response_model=list[ShiftRead])
async def get_week_schedule(
    year: int,
    week: int,
    session: Session = Depends(get_session),
    user: User = Depends(require_auth),
):
    shifts = session.exec(
        select(Shift)
            .where(
                extract("year", Shift.start) == year,
                extract("week", Shift.start) == week,
            )
    ).all()

    return [s.serialize() for s in shifts]


@router.get("/day/{year}/{month}/{day}", response_model=list[ShiftRead])
async def get_day_schedule(
    year: int,
    month: int,
    day: int,
    session: Session = Depends(get_session),
    _: User = Depends(require_auth),
):
    shifts = session.exec(
        select(Shift)
            .where(
                extract("year", Shift.start) == year,
                extract("month", Shift.start) == month,
                extract("day", Shift.start) == day,
            )
    ).all()

    return [s.serialize() for s in shifts]


@router.post("")
async def upload_schedule(
    background_tasks: BackgroundTasks,
    image: ImageData,
    session: Session = Depends(get_session),
    user: User = Depends(require_auth),
):
    if not user.admin:
        raise HTTPException(status_code=403)

    img_data = base64.b64decode(image.image)

    background_tasks.add_task(parse_schedule, img_data, user)

    return Response(status_code=202)


@router.patch("/shift/{shift_id}")
async def edit_shift(
    shift_id: str,
    data: ShiftUpdate,
    session: Session = Depends(get_session),
    user: User = Depends(require_auth)
):
    shift = session.exec(
        select(Shift)
            .where(Shift.id == shift_id)
    ).one_or_none()

    if not shift:
        return HTTPException(status_code=404)

    if not user.admin and shift.username != user.username:
        return HTTPException(status_code=403)

    if data.start is not None:
        shift.start = data.start

    if data.end is not None:
        shift.end = data.end

    if data.canceled is not None:
        shift.canceled = data.canceled

    if shift.canceled:
        shift.end = None

    s = shift.serialize()

    session.commit()

    return s


@router.get("/calendar/{enc_username}")
def get_ics_calendar(
    enc_username: str,
    session: Session = Depends(get_session)
):
    username = base64.b64decode(enc_username).decode("ascii").strip()

    user = session.exec(
        select(User)
            .where(User.username == username)
    ).one_or_none()

    if not user:
        raise HTTPException(status_code=404)

    settings = user.settings or UserSettings(username=user.username)

    shifts = session.exec(
        select(Shift)
            .where(Shift.username == user.username)
    ).all()

    calendar = Calendar()
    timezone = pytz.timezone("Europe/Amsterdam")

    for s in shifts:
        calendar.events.add(
            Event(
                uid=s.id,
                name=settings.calendar_event_title,
                begin=timezone.localize(s.start),
                end=timezone.localize(s.end or datetime.combine(s.start.date(), time(22, 0))),
                location=textwrap.dedent(
                    """
                        AH-UN Calypso
                        Mauritsweg 6
                        3012 JR Rotterdam
                        Netherlands
                    """).strip()
            )
        )

    return Response(
        content=calendar.serialize(),
        media_type="text/calendar",
        headers={
            "Content-Disposition": "attachment; filename=shifts.ics",
            "Cache-Control": "no-cache, no-store, must-revalidate"
        },
    )
