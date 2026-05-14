from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from routes.products import router as products_router
from routes.navigation import router as navigation_router

app = FastAPI(title="MercaCoders Backend", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(products_router)
app.include_router(navigation_router)


@app.get("/")
async def root():
    return {"message": "MercaCoders backend running"}
