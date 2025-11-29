"""
Order service for business logic
"""
from sqlalchemy.orm import Session
from app.models.order import Order, OrderItem
from app.schemas.order import OrderCreate, OrderUpdate
from typing import Optional, List
import uuid


class OrderService:
    """Order service class"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def get_user_orders(self, user_id: int, skip: int = 0, limit: int = 100, status: str = None) -> List[Order]:
        """Get user's orders"""
        query = self.db.query(Order).filter(Order.buyer_id == user_id)
        
        if status:
            query = query.filter(Order.status == status)
        
        return query.offset(skip).limit(limit).all()
    
    def get_order_by_id(self, order_id: int, user_id: int) -> Optional[Order]:
        """Get order by ID for specific user"""
        return self.db.query(Order).filter(
            Order.id == order_id,
            Order.buyer_id == user_id
        ).first()
    
    def create_order(self, order_data: OrderCreate, buyer_id: int) -> Order:
        """Create new order"""
        # Generate order number
        order_number = f"ORD-{uuid.uuid4().hex[:8].upper()}"
        
        # Calculate totals (simplified)
        subtotal = 0.0
        for item in order_data.items:
            # Get product price (simplified)
            product = self.db.query(Product).filter(Product.id == item.product_id).first()
            if product:
                subtotal += product.price * item.quantity
        
        total_amount = subtotal  # Simplified - no tax/shipping for now
        
        # Create order
        db_order = Order(
            order_number=order_number,
            buyer_id=buyer_id,
            subtotal=subtotal,
            total_amount=total_amount,
            shipping_address=order_data.shipping_address,
            shipping_city=order_data.shipping_city,
            shipping_state=order_data.shipping_state,
            shipping_country=order_data.shipping_country,
            shipping_postal_code=order_data.shipping_postal_code,
            notes=order_data.notes
        )
        
        self.db.add(db_order)
        self.db.flush()  # Get the order ID
        
        # Create order items
        for item in order_data.items:
            product = self.db.query(Product).filter(Product.id == item.product_id).first()
            if product:
                order_item = OrderItem(
                    order_id=db_order.id,
                    product_id=item.product_id,
                    quantity=item.quantity,
                    unit_price=product.price,
                    total_price=product.price * item.quantity,
                    product_title=product.title,
                    product_sku=product.sku
                )
                self.db.add(order_item)
        
        self.db.commit()
        self.db.refresh(db_order)
        return db_order
    
    def update_order(self, order_id: int, order_update: OrderUpdate, user_id: int) -> Optional[Order]:
        """Update order"""
        db_order = self.get_order_by_id(order_id, user_id)
        if not db_order:
            return None
        
        update_data = order_update.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(db_order, field, value)
        
        self.db.commit()
        self.db.refresh(db_order)
        return db_order
