"""
Product service for business logic
"""
from sqlalchemy.orm import Session
from app.models.product import Product
from app.schemas.product import ProductCreate, ProductUpdate
from typing import Optional, List


class ProductService:
    """Product service class"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def get_products(self, skip: int = 0, limit: int = 100, category: str = None, search: str = None) -> List[Product]:
        """Get products with optional filtering"""
        query = self.db.query(Product).filter(Product.is_active == True)
        
        if category:
            query = query.filter(Product.category == category)
        
        if search:
            query = query.filter(Product.title.ilike(f"%{search}%"))
        
        return query.offset(skip).limit(limit).all()
    
    def get_product_by_id(self, product_id: int) -> Optional[Product]:
        """Get product by ID"""
        return self.db.query(Product).filter(Product.id == product_id, Product.is_active == True).first()
    
    def create_product(self, product_data: ProductCreate, seller_id: int) -> Product:
        """Create new product"""
        db_product = Product(
            **product_data.dict(),
            seller_id=seller_id
        )
        self.db.add(db_product)
        self.db.commit()
        self.db.refresh(db_product)
        return db_product
    
    def update_product(self, product_id: int, product_update: ProductUpdate, seller_id: int) -> Optional[Product]:
        """Update product"""
        db_product = self.db.query(Product).filter(
            Product.id == product_id,
            Product.seller_id == seller_id,
            Product.is_active == True
        ).first()
        
        if not db_product:
            return None
        
        update_data = product_update.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_product, field, value)
        
        self.db.commit()
        self.db.refresh(db_product)
        return db_product
    
    def delete_product(self, product_id: int, seller_id: int) -> bool:
        """Delete product (soft delete)"""
        db_product = self.db.query(Product).filter(
            Product.id == product_id,
            Product.seller_id == seller_id,
            Product.is_active == True
        ).first()
        
        if not db_product:
            return False
        
        db_product.is_active = False
        self.db.commit()
        return True
