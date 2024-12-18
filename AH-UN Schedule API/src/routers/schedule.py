from fastapi import APIRouter, Depends, HTTPException, Response
from sqlmodel import Session, extract, select
from tabulate import tabulate
import base64

from src.database import get_session
from src.middleware.auth import require_auth
from src.models.shift import Shift, ShiftRead
from src.models.user import User
from src.services.extract import extract_table_from_image, convert_table_to_shifts
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
    _: User = Depends(require_auth),
):
    shifts = session.exec(
        select(Shift)
            .where(
                extract("year", Shift.start) == year,
                extract("week", Shift.start) == week,
            )
    ).all()

    return [s.serialize() for s in shifts]


@router.post("")
async def upload_schedule(
    image: ImageData,
    session: Session = Depends(get_session),
    user: User = Depends(require_auth),
):
    if not user.admin:
        raise HTTPException(status_code=403)

    img_data = base64.b64decode(image.image)

    data = extract_table_from_image(img_data)
    data = [r for i, r in enumerate(data) if i == 0 or len(r[0])]

    print(tabulate(data, headers="firstrow", tablefmt="rounded_grid"))

    shifts = convert_table_to_shifts(session, data)

    for s in shifts:
        session.add(s)

    session.commit()

    return Response(status_code=201)
