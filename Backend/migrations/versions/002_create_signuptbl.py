"""Create signuptbl table

Revision ID: 002
Revises: 001
Create Date: 2024-11-22 00:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql
from datetime import datetime

# revision identifiers, used by Alembic.
revision = '002'
down_revision = '001'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Create signuptbl table
    op.create_table('signuptbl',
        sa.Column('id', sa.Integer(), nullable=False, autoincrement=True),
        sa.Column('user_id', sa.String(length=20), nullable=False, unique=True, index=True),
        sa.Column('email', sa.String(length=255), nullable=False, unique=True, index=True),
        sa.Column('first_name', sa.String(length=100), nullable=False),
        sa.Column('last_name', sa.String(length=100), nullable=False),
        sa.Column('phone_number', sa.String(length=20), nullable=False, unique=True, index=True),
        sa.Column('hashed_password', sa.String(length=255), nullable=False),
        sa.Column('gender', sa.String(length=50), nullable=False),
        sa.Column('location', sa.String(length=255), nullable=False),
        sa.Column('occupation', sa.String(length=50), nullable=True),
        sa.Column('source_of_funds', sa.String(length=50), nullable=True),
        sa.Column('timezone', sa.String(length=100), nullable=True),
        sa.Column('additional_properties', postgresql.JSON(astext_type=sa.Text()), nullable=True),
        sa.Column('status', sa.String(length=50), nullable=False, default='CREATED'),
        sa.Column('created_on', sa.DateTime(), nullable=False, default=datetime.utcnow),
        sa.Column('updated_on', sa.DateTime(), nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow),
        sa.PrimaryKeyConstraint('id')
    )
    
    # Create indexes for better query performance
    op.create_index(op.f('ix_signuptbl_email'), 'signuptbl', ['email'], unique=True)
    op.create_index(op.f('ix_signuptbl_phone_number'), 'signuptbl', ['phone_number'], unique=True)
    op.create_index(op.f('ix_signuptbl_user_id'), 'signuptbl', ['user_id'], unique=True)
    op.create_index('ix_signuptbl_created_on', 'signuptbl', ['created_on'])


def downgrade() -> None:
    op.drop_index('ix_signuptbl_created_on', table_name='signuptbl')
    op.drop_index(op.f('ix_signuptbl_user_id'), table_name='signuptbl')
    op.drop_index(op.f('ix_signuptbl_phone_number'), table_name='signuptbl')
    op.drop_index(op.f('ix_signuptbl_email'), table_name='signuptbl')
    op.drop_table('signuptbl')



