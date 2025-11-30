"""
Frame Validation routes
"""
from fastapi import APIRouter, Body, status

router = APIRouter()


@router.post(
    "/register",
    tags=["2. Frame Validation"],
    summary="Register frame validation request",
    status_code=status.HTTP_200_OK,
)
async def register_frame_validation(
    payload: dict = Body(
        ..., description="Generic payload for frame validation (e.g., imageUrl, metadata)"
    )
):
    """Accept a frame validation request payload and acknowledge receipt."""
    return {"status": "received", "payload": payload}
