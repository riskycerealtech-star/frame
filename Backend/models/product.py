"""
Product model for marketplace items
"""
from sqlalchemy import Column, String, Text, Integer, Float, Boolean, ForeignKey, Enum, DateTime
from sqlalchemy.orm import relationship
from app.db.base import Base
import enum


class ProductCategory(str, enum.Enum):
    """Product categories"""
    SUNGLASSES = "sunglasses"
    EYEGLASSES = "eyeglasses"
    CONTACT_LENSES = "contact_lenses"
    ACCESSORIES = "accessories"
    REPAIR_SERVICES = "repair_services"


class ProductCondition(str, enum.Enum):
    """Product condition"""
    NEW = "new"
    LIKE_NEW = "like_new"
    GOOD = "good"
    FAIR = "fair"
    POOR = "poor"


class Product(Base):
    """Product model for marketplace items"""
    
    __tablename__ = "products"
    
    # Basic product information
    title = Column(String(255), nullable=False, index=True)
    description = Column(Text, nullable=True)
    category = Column(Enum(ProductCategory), nullable=False)
    condition = Column(Enum(ProductCondition), nullable=False)
    
    # Pricing
    price = Column(Float, nullable=False)
    currency = Column(String(3), default="USD", nullable=False)
    
    # Inventory
    quantity_available = Column(Integer, default=1, nullable=False)
    sku = Column(String(100), unique=True, index=True, nullable=True)
    
    # Seller information
    seller_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    
    # Product details
    brand = Column(String(100), nullable=True)
    model = Column(String(100), nullable=True)
    color = Column(String(50), nullable=True)
    size = Column(String(50), nullable=True)
    material = Column(String(100), nullable=True)
    
    # Images
    primary_image_url = Column(String(500), nullable=True)
    image_urls = Column(Text, nullable=True)  # JSON string of image URLs
    
    # AI Validation
    ai_validated = Column(Boolean, default=False, nullable=False)
    ai_confidence = Column(Float, nullable=True)
    ai_validation_date = Column(DateTime, nullable=True)
    
    # Status
    is_featured = Column(Boolean, default=False, nullable=False)
    is_approved = Column(Boolean, default=True, nullable=False)
    
    # Relationships
    seller = relationship("User", back_populates="products")
    order_items = relationship("OrderItem", back_populates="product")
    reviews = relationship("Review", back_populates="product")
    images = relationship("ProductImage", back_populates="product")
