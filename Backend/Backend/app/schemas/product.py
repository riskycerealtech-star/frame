"""
Product schemas for request/response models
"""
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from app.models.product import ProductCategory, ProductCondition


class ProductBase(BaseModel):
    """Base product schema"""
    title: str
    description: Optional[str] = None
    category: ProductCategory
    condition: ProductCondition
    price: float
    currency: str = "USD"
    quantity_available: int = 1
    brand: Optional[str] = None
    model: Optional[str] = None
    color: Optional[str] = None
    size: Optional[str] = None
    material: Optional[str] = None


class ProductCreate(ProductBase):
    """Product creation schema"""
    pass


class ProductUpdate(BaseModel):
    """Product update schema"""
    title: Optional[str] = None
    description: Optional[str] = None
    category: Optional[ProductCategory] = None
    condition: Optional[ProductCondition] = None
    price: Optional[float] = None
    currency: Optional[str] = None
    quantity_available: Optional[int] = None
    brand: Optional[str] = None
    model: Optional[str] = None
    color: Optional[str] = None
    size: Optional[str] = None
    material: Optional[str] = None
    primary_image_url: Optional[str] = None


class ProductResponse(ProductBase):
    """Product response schema"""
    id: int
    seller_id: int
    sku: Optional[str] = None
    primary_image_url: Optional[str] = None
    image_urls: Optional[str] = None
    ai_validated: bool
    ai_confidence: Optional[float] = None
    ai_validation_date: Optional[datetime] = None
    is_featured: bool
    is_approved: bool
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


class ProductImageResponse(BaseModel):
    """Product image response schema"""
    id: int
    product_id: int
    image_url: str
    thumbnail_url: Optional[str] = None
    alt_text: Optional[str] = None
    display_order: int
    is_primary: bool
    ai_validated: bool
    ai_confidence: Optional[float] = None
    
    class Config:
        from_attributes = True
