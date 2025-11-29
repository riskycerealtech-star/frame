"""
Order schemas for request/response models
"""
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime
from app.models.order import OrderStatus, PaymentStatus


class OrderItemCreate(BaseModel):
    """Order item creation schema"""
    product_id: int
    quantity: int


class OrderCreate(BaseModel):
    """Order creation schema"""
    items: List[OrderItemCreate]
    shipping_address: Optional[str] = None
    shipping_city: Optional[str] = None
    shipping_state: Optional[str] = None
    shipping_country: Optional[str] = None
    shipping_postal_code: Optional[str] = None
    notes: Optional[str] = None


class OrderUpdate(BaseModel):
    """Order update schema"""
    status: Optional[OrderStatus] = None
    payment_status: Optional[PaymentStatus] = None
    tracking_number: Optional[str] = None
    notes: Optional[str] = None


class OrderItemResponse(BaseModel):
    """Order item response schema"""
    id: int
    order_id: int
    product_id: int
    quantity: int
    unit_price: float
    total_price: float
    product_title: str
    product_sku: Optional[str] = None
    
    class Config:
        from_attributes = True


class OrderResponse(BaseModel):
    """Order response schema"""
    id: int
    order_number: str
    buyer_id: int
    status: OrderStatus
    payment_status: PaymentStatus
    subtotal: float
    tax_amount: float
    shipping_amount: float
    total_amount: float
    currency: str
    shipping_address: Optional[str] = None
    shipping_city: Optional[str] = None
    shipping_state: Optional[str] = None
    shipping_country: Optional[str] = None
    shipping_postal_code: Optional[str] = None
    tracking_number: Optional[str] = None
    estimated_delivery: Optional[datetime] = None
    delivered_at: Optional[datetime] = None
    notes: Optional[str] = None
    created_at: datetime
    updated_at: datetime
    order_items: List[OrderItemResponse] = []
    
    class Config:
        from_attributes = True
