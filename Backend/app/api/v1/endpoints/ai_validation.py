"""
AI validation endpoints for sunglasses detection
"""
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.services.ai_validation_service import AIValidationService
from app.schemas.ai_validation import ValidationRequest, ValidationResponse

router = APIRouter()


@router.post("/validate-sunglasses", response_model=ValidationResponse, tags=["2. Publish Flame"])
async def validate_sunglasses(
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    """Validate if uploaded image contains sunglasses"""
    try:
        # Validate file type
        if not file.content_type or not file.content_type.startswith('image/'):
            raise HTTPException(
                status_code=400,
                detail="Invalid file type. Please upload an image file."
            )
        
        # Read image content
        image_content = await file.read()
        
        if len(image_content) == 0:
            raise HTTPException(status_code=400, detail="Empty file uploaded")
        
        # Validate image using AI service
        ai_service = AIValidationService()
        result = await ai_service.validate_sunglasses(image_content)
        
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"AI validation failed: {str(e)}"
        )


@router.post("/validate-sunglasses-base64", response_model=ValidationResponse, tags=["2. Publish Flame"])
async def validate_sunglasses_base64(
    request: ValidationRequest,
    db: Session = Depends(get_db)
):
    """Validate base64 encoded image for sunglasses"""
    try:
        import base64
        
        # Decode base64 image
        try:
            image_content = base64.b64decode(request.image)
        except Exception as e:
            raise HTTPException(
                status_code=400,
                detail="Invalid base64 image data"
            )
        
        # Validate image using AI service
        ai_service = AIValidationService()
        result = await ai_service.validate_sunglasses(image_content)
        
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"AI validation failed: {str(e)}"
        )
