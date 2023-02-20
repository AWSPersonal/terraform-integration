from fastapi import FastAPI, Request
from mangum import Mangum
from shared_services import custom, helpers
from starlette.middleware.cors import CORSMiddleware
import dispatches.routes.api as dispatches_router

lambdaPaths = helpers.override_path()

if lambdaPaths["staging"] is None:
    fastapi_doc = None
else:
    fastapi_doc = f'{lambdaPaths["staging"]}/{lambdaPaths["resource"]}'

app = FastAPI(root_path=fastapi_doc)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.middleware("http")
async def add_cors_header(request: Request, call_next):
    response = await call_next(request)
    response.headers["Access-Control-Allow-Headers"] = "Content-Type"
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "*"
    return response

@app.get("/")
async def root():
    tex = custom.hello()
    return {
        "message": "Hello From Dispatches",
        "shared": tex
    }
    
app.include_router(dispatches_router.router, prefix="/dispatches/api/v1")

handler = Mangum(app, api_gateway_base_path=lambdaPaths["resource"])
