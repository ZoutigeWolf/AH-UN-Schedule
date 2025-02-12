import os
import cv2
from pydantic import BaseModel
import pytesseract
import numpy as np
from datetime import datetime
import unicodedata
from openai import OpenAI
import json
from sqlmodel import Session, extract, select
from tabulate import tabulate

from src.database import engine
from src.models.shift import Shift
from src.models.user import User
from src.models.user_settings import UserSettings
from src.services.notifications import send_notification

CELL_SIZE = (79, 23)
BORDER_WIDTH = 1

openai_client = OpenAI(api_key=os.getenv("OPENAI_KEY"))


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


def clean_table_with_openai(table: list[list[str]]):
    class CleanedTable(BaseModel):
        table: list[list[str]]

    res = openai_client.beta.chat.completions.parse(
        model="gpt-4o",
        messages=[
            {
                "role": "user",
                "content": f"""
                {table}

                You are a data input scientist that cleans up data for database storage
                Take the above input data and clean all strings

                Cleanup any errors caused by OCR like extra characters make sure each time is formatted as HH:MM
                Unicode normalize all characters

                Reformat the dates in the first row using format: yyyy-mm-dd
                The day this data is uploaded is {datetime.now()}, choose the right year based on this date
                The first column contains the names for each person
                Clean up all the names removing any dots or other weird characters

                All the other cells contain times when a shift starts for a specific person on a specific day
                if the cell contains any prefixes, suffixes or anomalies: clean them up so that only the value remains

                Format the times according to these rules:
                \"x\" means 11:00
                \"L\" means 14:00 on wednesday and thursday, else it is 15:00
                \"V\" or \"Vv\" means 11:00

                Examples:
                \"17:00afw\" becomes \"17:00\"
                \"L keuken\" becomes \"14:00\" or \"15:00\" depending on the date
                \"18:00\" becomes \"18:00\"
                \"V\" becomes \"11:00\"
                \"Vv\" becomes \"11:00\"

                Make sure the the scheduled times stay on the correct index in the row by comparing the end result with the original data
                """
            }
        ],
        response_format=CleanedTable
    )

    data = json.loads(json.loads(res.choices[0].json())["message"]["content"])["table"]

    print(tabulate(data, headers="firstrow", tablefmt="rounded_grid"))

    return data


def convert_table_to_shifts(session: Session, table: list[list[str]]) -> list[Shift]:
    shifts = []

    dates = [datetime.strptime(s, "%Y-%m-%d") for s in table[0][1:]]

    for row in table[1:]:
        name = row[0]
        username = name.lower().replace(" ", "")

        user = session.exec(select(User).where(User.username == username)).one_or_none()

        if not user:
            user = User(username=username, name=name, password_hash=os.urandom(32), admin=False)
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


def parse_schedule(img_data: bytes, user: User):
    with Session(engine) as session:
        try:
            print("Extracting text from image...")
            data = extract_table_from_image(img_data)
            data = [r for i, r in enumerate(data) if i == 0 or len(r[0])]

            print(tabulate(data, headers="firstrow", tablefmt="rounded_grid"))

            print("Cleaning data...")
            data = clean_table_with_openai(data)

            print("Parsing shifts...")
            shifts = convert_table_to_shifts(session, data)

            year, week = shifts[0].start.isocalendar()[:2]

            existing_shifts = session.exec(
                select(Shift)
                    .where(
                        extract("year", Shift.start) == year,
                        extract("week", Shift.start) == week
                    )
            )

            for s in existing_shifts:
                session.delete(s)

            for s in shifts:
                session.add(s)

            session.commit()

            print("Done")

        except Exception as e:
            send_notification(
                user,
                title="Schedule parsing error",
                body=str(e)
            )

            return

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

            if not settings.notifications_new_schedule:
                continue

            send_notification(
                u,
                title="New schedule",
                body=f"The schedule for week {week} is now available"
            )
