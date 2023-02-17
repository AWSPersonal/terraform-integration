from fastapi import FastAPI
from mangum import Mangum
from shared_services import custom

app = FastAPI()


@app.get("/")
async def root():
    tex = custom.hello()
    return {
        "message": "Hello From Dispatches",
        "shared": tex
    }

handler = Mangum(app)
