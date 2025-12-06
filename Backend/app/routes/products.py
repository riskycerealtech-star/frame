"""
Product management endpoints
"""
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from app.db.session import get_db
from app.schemas.product import ProductResponse, ProductCreate, ProductUpdate
from app.services.product_service import ProductService
from app.api.v1.dependencies import get_current_user

router = APIRouter()


@router.get("/", response_model=List[ProductResponse])
async def get_products(
    skip: int = Query(0, ge=0),
    limit: int = Query(100, ge=1, le=100),
    category: Optional[str] = None,
    search: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """Get list of products with optional filtering"""
    product_service = ProductService(db)
    products = product_service.get_products(
        skip=skip,
        limit=limit,
        category=category,
        search=search
    )
    return products


@router.get("/{product_id}", response_model=ProductResponse)
async def get_product(
    product_id: int,
    db: Session = Depends(get_db)
):
    """Get product by ID"""
    product_service = ProductService(db)
    product = product_service.get_product_by_id(product_id)
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found"
        )
    return product


@router.post("/", response_model=ProductResponse)
async def create_product(
    product_data: ProductCreate,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Create a new product"""
    product_service = ProductService(db)
    product = product_service.create_product(product_data, current_user["id"])
    return product


@router.put("/{product_id}", response_model=ProductResponse)
async def update_product(
    product_id: int,
    product_update: ProductUpdate,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update product (only by owner)"""
    product_service = ProductService(db)
    product = product_service.update_product(
        product_id, product_update, current_user["id"]
    )
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found or not authorized"
        )
    return product


@router.delete("/{product_id}")
async def delete_product(
    product_id: int,
    current_user: dict = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete product (only by owner)"""
    product_service = ProductService(db)
    success = product_service.delete_product(product_id, current_user["id"])
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Product not found or not authorized"
        )
    return {"message": "Product deleted successfully"}
