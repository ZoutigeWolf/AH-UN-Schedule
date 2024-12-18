import os
import cv2
import pytesseract
import numpy as np
from datetime import datetime
import unicodedata

from sqlmodel import Session, select

from src.models.shift import Shift
from src.models.user import User

CELL_SIZE = (79, 23)
BORDER_WIDTH = 1

def extract_table_from_image(image: bytes) -> list[list[str]]:
    img = cv2.imdecode(np.frombuffer(image, np.uint8), cv2.IMREAD_COLOR)

    t = 15
    mask = cv2.inRange(img, np.array([198 - t, 175 - t, 110 - t]), np.array([198 + t, 175 + t, 110 + t]))
    img[mask == 255] = (60, 55, 50)

    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    _, binary = cv2.threshold(gray, 150, 255, cv2.THRESH_BINARY_INV)

    table = []
    for y in range(BORDER_WIDTH, img.shape[0], CELL_SIZE[1] + BORDER_WIDTH):
        row = []
        for idx, x in enumerate(range(0, img.shape[1], CELL_SIZE[0] + BORDER_WIDTH)):
            if idx > 14:
                continue

            if idx != 0 and idx % 2 == 0:
                continue

            if idx == 0:
                cell_img = binary[y : y + CELL_SIZE[1] - 1, x : x + CELL_SIZE[0]]
            else:
               cell_img = binary[y : y + CELL_SIZE[1] - 1, x + 1 : x + (CELL_SIZE[0] * 2) - 1]

            text = pytesseract.image_to_string(cell_img, config="--psm 6").strip()
            text = "".join(c for c in unicodedata.normalize('NFKD', text) if not unicodedata.combining(c))
            row.append(text)

        table.append(row)

    return table


def convert_table_to_shifts(session: Session, table: list[list[str]]) -> list[Shift]:
    shifts = []

    dates = [datetime.strptime(s.split(" ")[1].replace("-", " ") + f" {datetime.now().year}", "%d %b %Y") for s in table[0][1:]]

    for row in table[1:]:
        name = row[0]

        user = session.exec(select(User).where(User.name == name)).one_or_none()

        if not user:
            user = User(username=name.lower(), name=name, password_hash=os.urandom(32), admin=False)
            session.add(user)

        times  = []

        for idx, s in enumerate(row[1:]):
            if len(s) == 0:
                continue

            try:
                d = datetime.combine(dates[idx], datetime.strptime(s[:5], "%H:%M").time())

            except ValueError:
                continue

            times.append(d)

        for t in times:
            shifts.append(
                Shift(
                    username=user.username,
                    start=t,
                    end=None
                )
            )

    return shifts
