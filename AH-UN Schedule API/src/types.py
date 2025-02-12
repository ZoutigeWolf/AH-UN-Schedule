from sqlmodel import SQLModel

from src.models.shift import ShiftRead


class LoginCredentials(SQLModel):
    username: str
    password: str


class ImageData(SQLModel):
    image: str


class DeviceInfo(SQLModel):
    device: str


class Insights(SQLModel):
    days: int
    hours: float
    salary: float
    average_shift_length: dict[int, float]
    shifts: list[ShiftRead]
