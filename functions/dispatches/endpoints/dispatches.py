
"""Tags route contains all the tag related endpoints"""

from fastapi import APIRouter

router = APIRouter()


@router.put("/dispatches")
async def get_dispatches(name: str, number: int):
    """Will add or edit tags"""
    return {"message": f"Hello {name}!!! with a number {number}"}
