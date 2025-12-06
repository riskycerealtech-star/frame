"""
Order management endpoints
"""
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from app.db.session import get_db
from app.schemas.order import OrderResponse, OrderCreate, OrderUpdate
from app.services.order_service import OrderService
from app.api.v1.dependencies import get_current_user

router = APIRouter()


@router.get("/", response_model=List[OrderResponse])
async def get_orders(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=100),
    status: Optional[str] = None,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get user's orders"""
    order_service = OrderService(db)
    orders = order_service.get_user_orders(
        user_id=current_user["id"],
        skip=skip,
        limit=limit,
        status=status
    )
    return orders


@router.get("/{order_id}", response_model=OrderResponse)
async def get_order(
    order_id: int,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Get order by ID"""
    order_service = OrderService(db)
    order = order_service.get_order_by_id(order_id, current_user["id"])
    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Order not found"
        )
    return order


@router.post("/", response_model=OrderResponse)
async def create_order(
    order_data: OrderCreate,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a new order"""
    order_service = OrderService(db)
    order = order_service.create_order(order_data, current_user["id"])
    return order


@router.put("/{order_id}", response_model=OrderResponse)
async def update_order(
    order_id: int,
    order_update: OrderUpdate,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update order status"""
    order_service = OrderService(db)
    order = order_service.update_order(
        order_id, order_update, current_user["id"]
    )
    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Order not found or not authorized"
        )
    return order
