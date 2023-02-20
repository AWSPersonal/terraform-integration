from fastapi import APIRouter
from dispatches.endpoints import tags

router = APIRouter()
router.include_router(tags.router, prefix="/tags", tags=["tags"])