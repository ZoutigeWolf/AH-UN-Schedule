from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import PlainTextResponse
from fastapi_utils.tasks import repeat_every
from sqlmodel import Session, col, select
from datetime import datetime, timedelta
import textwrap
import pytz

from src.database import engine
from src.models.shift import Shift
from src.models.user import User
from src.routers import AuthRouter, ScheduleRouter, UsersRouter, InsightsRouter
from src.models.user_settings import UserSettings
from src.services.notifications import send_notification

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"]
)

app.include_router(AuthRouter)
app.include_router(ScheduleRouter)
app.include_router(UsersRouter)
app.include_router(InsightsRouter)


@app.get("/privacy", response_class=PlainTextResponse)
async def privacy():
    return textwrap.dedent("""
        Privacy Policy

        We value your privacy. Our app does not collect, store, or share any personal information.
        We do not track your location, collect data for advertising, or use third-party analytics services
        that require data collection. Any data voluntarily provided by the user will be used solely for
        the purpose of app functionality and will not be shared with third parties.

        If we decide to make any changes to this policy, we will notify you through an updated policy
        available within the app.

        For questions or concerns, please contact us at guuskamphuis@gmail.com.
    """).strip()


@app.on_event("startup")
@repeat_every(seconds=60)
async def notification_loop():
    tz = pytz.timezone("Europe/Amsterdam")

    with Session(engine) as session:
        users = session.exec(
            select(User)
        ).all()

        for u in users:
            settings = session.exec(
                select(UserSettings)
                .where(UserSettings.username == u.username)
            ).one_or_none()

            if not settings:
                settings = UserSettings(username=u.username)

            if not settings.notifications_work_reminder:
                continue

            next_shift = session.exec(
                select(Shift)
                .where(
                    Shift.username == u.username,
                    Shift.start > datetime.now(tz),
                    Shift.start < (datetime.now(tz) + timedelta(hours=12))
                )
                .order_by(col(Shift.start))
                .limit(1)
            ).first()

            if not next_shift:
                continue

            m_diff = (tz.localize(next_shift.start) - datetime.now(tz)).total_seconds() // 60

            if m_diff != (settings.notifications_work_reminder_time * 60):
                continue

            h = int(m_diff // 60)
            m = int(m_diff % 60)

            send_notification(
                user=u,
                title=(
                    f"Your shift starts in {h} {'hour' if h == 1 else 'hours'}"
                    if h > 0 else
                    f"Your shift starts in {m} {'minute' if m == 1 else 'minutes'}"
                ),
                body=f"You start at {next_shift.start.strftime("%-H:%M")}, get ready!"
            )
