from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

import src.database
from src.routers import AuthRouter, ScheduleRouter, UsersRouter

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"]
)

app.include_router(AuthRouter)
app.include_router(ScheduleRouter)
app.include_router(UsersRouter)
