"""
Product image model for storing image metadata
"""
from sqlalchemy import Column, String, Text, Integer, Float, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from app.db.base import Base


class ProductImage(Base):
    """Product image model"""
    
    __tablename__ = "product_images"
    
    # References
    product_id = Column(Integer, ForeignKey("products.id"), nullable=False)
    
    # Image information
    image_url = Column(String(500), nullable=False)
    thumbnail_url = Column(String(500), nullable=True)
    alt_text = Column(String(255), nullable=True)
    
    # Image metadata
    file_size = Column(Integer, nullable=True)
    width = Column(Integer, nullable=True)
    height = Column(Integer, nullable=True)
    format = Column(String(10), nullable=True)  # jpg, png, webp, etc.
    
    # Display order
    display_order = Column(Integer, default=0, nullable=False)
    is_primary = Column(Boolean, default=False, nullable=False)
    
    # AI Validation
    ai_validated = Column(Boolean, default=False, nullable=False)
    ai_confidence = Column(Float, nullable=True)
    ai_validation_result = Column(Text, nullable=True)  # JSON string
    
    # Relationships
    product = relationship("Product", back_populates="images")
