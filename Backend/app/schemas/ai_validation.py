"""
AI validation schemas
"""
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from datetime import datetime


class ValidationRequest(BaseModel):
    """AI validation request schema"""
    image: str  # Base64 encoded image


class ObjectDetection(BaseModel):
    """Object detection result"""
    object: str
    confidence: float
    bounding_box: Dict[str, float]


class LabelDetection(BaseModel):
    """Label detection result"""
    label: str
    confidence: float


class ValidationResponse(BaseModel):
    """AI validation response schema"""
    status: str  # "accepted" or "rejected"
    confidence: float
    message: str
    details: str
    analysis: Dict[str, Any]
    timestamp: str
    
    class Config:
        from_attributes = True
