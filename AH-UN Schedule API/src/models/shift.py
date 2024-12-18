from sqlmodel import Relationship, SQLModel, Field
from datetime import datetime
import uuid

class ShiftBase(SQLModel):
    id: str
    username: str
    start: datetime
    end: datetime | None


class Shift(ShiftBase, table=True):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()), primary_key=True)
    username: str = Field(foreign_key="user.username", index=True)
    start: datetime = Field(index=True)
    end: datetime | None = Field(default=None)

    user: "User" = Relationship(back_populates="shifts")

    def serialize(self) -> "ShiftRead":
        s = self.model_dump()

        s["user"] = self.user

        return ShiftRead(**s)


class ShiftRead(ShiftBase):
    user: "UserRead"


from src.models.user import User, UserRead