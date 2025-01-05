"""shift_canceled

Revision ID: 238eb64392ea
Revises: d161700074b1
Create Date: 2024-12-21 21:26:16.416209

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '238eb64392ea'
down_revision: Union[str, None] = 'd161700074b1'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # ### commands auto generated by Alembic - please adjust! ###
    op.add_column('shift', sa.Column('canceled', sa.Boolean(), nullable=True))
    # ### end Alembic commands ###


def downgrade() -> None:
    # ### commands auto generated by Alembic - please adjust! ###
    op.drop_column('shift', 'canceled')
    # ### end Alembic commands ###