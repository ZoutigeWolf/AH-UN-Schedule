from fastapi import APIRouter, Depends
from sqlmodel import Session, select, extract, case, col, func, Integer
from datetime import datetime, time
import pytz

from src.database import get_session
from src.middleware.auth import require_auth
from src.models.shift import Shift
from src.models.user import User
from src.models.user_settings import UserSettings
from src.types import Insights


router = APIRouter(
    prefix="/insights",
    tags=["Insights"]
)


@router.get("/{year}/{month}", response_model=Insights)
async def get_monthly_insights(
    year: int,
    month: int,
    session: Session = Depends(get_session),
    user: User = Depends(require_auth),
):
    settings = session.exec(
        select(UserSettings)
            .where(UserSettings.username == user.username)
    ).one_or_none()

    if not settings:
        settings = UserSettings(username=user.username)

    shifts = session.exec(
        select(Shift)
            .where(
                Shift.username == user.username,
                Shift.canceled != True,
                extract("year", Shift.start) == year,
                extract("month", Shift.start) == month,
                case(
                    (col(Shift.end).isnot(None), Shift.end),
                    else_=func.make_timestamp(
                        extract("year", Shift.start).cast(Integer),
                        extract("month", Shift.start).cast(Integer),
                        extract("day", Shift.start).cast(Integer),
                        22, 0, 0
                    )
                ) < datetime.now(pytz.timezone("Europe/Amsterdam"))
            )
    ).all()

    days = len(shifts)
    hours = sum([
            ((s.end or datetime.combine(s.start.date(), time(22, 0))) - s.start).total_seconds() / 3600
            for s in shifts
    ])
    salary = hours * settings.wage
    avg_shift_length = {i: [] for i in range(7)}

    for s in shifts:
        h = ((s.end or datetime.combine(s.start.date(), time(22, 0))) - s.start).total_seconds() / 3600
        avg_shift_length[s.start.weekday()].append(h)

    avg_shift_length = {k: (sum(v) / len(v)) if v else 0 for k, v in avg_shift_length.items()}

    all_shifts = session.exec(
        select(Shift)
            .where(
                Shift.username == user.username,
                extract("year", Shift.start) == year,
                extract("month", Shift.start) == month,
            )
    ).all()

    return Insights(
        days=days,
        hours=hours,
        salary=salary,
        average_shift_length=avg_shift_length,
        shifts=[s.serialize() for s in all_shifts]
    )
