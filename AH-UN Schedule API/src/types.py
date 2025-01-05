from sqlmodel import SQLModel


class LoginCredentials(SQLModel):
    username: str
    password: str


class ImageData(SQLModel):
    image: str


class DeviceInfo(SQLModel):
    device: str
