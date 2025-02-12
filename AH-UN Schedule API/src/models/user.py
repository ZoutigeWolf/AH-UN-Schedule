from typing import Optional
from sqlmodel import Relationship, SQLModel, Field

class UserBase(SQLModel):
    username: str
    name: str
    admin: bool


class User(UserBase, table=True):
    username: str = Field(primary_key=True)
    name: str = Field()
    password_hash: bytes = Field()
    admin: bool = Field()

    shifts: list["Shift"] = Relationship(back_populates="user", sa_relationship_kwargs={"cascade": "all, delete-orphan"})
    devices: list["UserDevice"] = Relationship(back_populates="user", sa_relationship_kwargs={"cascade": "all, delete-orphan"})
    settings: Optional["UserSettings"] = Relationship(back_populates="user", sa_relationship_kwargs={"cascade": "all, delete-orphan"})

    def serialize(self) -> "UserRead":
        u = self.model_dump()

        return UserRead(**u)

class UserRead(UserBase):
    pass


class UserUpdate(SQLModel):
    admin: bool | None


class UserUpdatePassword(SQLModel):
    auth_password: str
    new_password: str


from src.models.shift import Shift
from src.models.user_device import UserDevice
from src.models.user_settings import UserSettings
