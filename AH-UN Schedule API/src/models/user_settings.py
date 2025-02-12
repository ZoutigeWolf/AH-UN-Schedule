from sqlmodel import Relationship, SQLModel, Field


class UserSettingsBase(SQLModel):
    username: str
    wage: float
    calendar_event_title: str
    notifications_new_schedule: bool
    notifications_work_reminder: bool
    notifications_work_reminder_time: float


class UserSettings(UserSettingsBase, table=True):
    username: str = Field(primary_key=True, foreign_key="user.username")
    wage: float = Field(default=0)
    calendar_event_title: str = Field(default="Work")
    notifications_new_schedule: bool = Field(default=True)
    notifications_work_reminder: bool = Field(default=True)
    notifications_work_reminder_time: float = Field(default=1.0)

    user: "User" = Relationship(back_populates="settings")


class UserSettingsUpdate(SQLModel):
    wage: float | None
    calendar_event_title: str | None
    notifications_new_schedule: bool | None
    notifications_work_reminder: bool | None
    notifications_work_reminder_time: float | None


from src.models.user import User
