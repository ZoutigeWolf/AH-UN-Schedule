from sqlmodel import Relationship, SQLModel, Field

class UserDeviceBase(SQLModel):
    username: str
    device: str


class UserDevice(UserDeviceBase, table=True):
    username: str = Field(primary_key=True, foreign_key="user.username")
    device: str = Field(primary_key=True)

    user: "User" = Relationship(back_populates="devices")


from src.models.user import User
