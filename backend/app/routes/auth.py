"""
AirEase Backend - Authentication Routes
User registration, login, and profile endpoints
"""

from fastapi import APIRouter, HTTPException, Depends, status, Header
from sqlalchemy.orm import Session
from typing import Optional

from app.database import get_db, UserDB
from app.models import UserCreate, UserLogin, Token, UserResponse
from app.services.auth_service import auth_service

router = APIRouter(prefix="/v1/auth", tags=["Authentication"])


# ============================================================
# Helper Functions
# ============================================================

def get_current_user(
    authorization: Optional[str] = Header(None),
    db: Session = Depends(get_db)
) -> Optional[UserDB]:
    """
    Dependency to get current user from Authorization header.
    Returns None if not authenticated (for optional auth).
    """
    if not authorization or not authorization.startswith("Bearer "):
        return None

    token = authorization.split(" ")[1]
    payload = auth_service.decode_token(token)

    if not payload:
        return None

    user_id = payload.get("user_id")
    if not user_id:
        return None

    user = db.query(UserDB).filter(UserDB.id == user_id).first()
    return user


def require_auth(
    authorization: Optional[str] = Header(None),
    db: Session = Depends(get_db)
) -> UserDB:
    """
    Dependency that requires authentication.
    Raises 401 if not authenticated.
    """
    user = get_current_user(authorization, db)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Not authenticated",
            headers={"WWW-Authenticate": "Bearer"}
        )
    return user


# ============================================================
# Authentication Endpoints
# ============================================================

@router.post(
    "/register",
    response_model=Token,
    status_code=status.HTTP_201_CREATED,
    summary="Register new user",
    description="Create a new user account and return JWT token"
)
async def register(user_data: UserCreate, db: Session = Depends(get_db)):
    """
    Register a new user.

    - **email**: Valid email address (must be unique)
    - **username**: Display name (3-50 characters)
    - **password**: Password (minimum 6 characters)

    Returns JWT token on successful registration.
    """
    # Check if email already exists
    existing_user = db.query(UserDB).filter(UserDB.email == user_data.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )

    # Create new user
    hashed_password = auth_service.hash_password(user_data.password)
    db_user = UserDB(
        email=user_data.email,
        username=user_data.username,
        hashed_password=hashed_password
    )

    db.add(db_user)
    db.commit()
    db.refresh(db_user)

    # Generate token
    access_token, expires_in = auth_service.create_access_token(
        user_id=db_user.id,
        email=db_user.email
    )

    return Token(
        access_token=access_token,
        token_type="bearer",
        expires_in=expires_in,
        user=UserResponse.model_validate(db_user)
    )


@router.post(
    "/login",
    response_model=Token,
    summary="Login",
    description="Authenticate user and return JWT token"
)
async def login(credentials: UserLogin, db: Session = Depends(get_db)):
    """
    Login with email and password.

    - **email**: Registered email address
    - **password**: Account password

    Returns JWT token on successful authentication.
    """
    # Find user by email
    user = db.query(UserDB).filter(UserDB.email == credentials.email).first()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )

    # Verify password
    if not auth_service.verify_password(credentials.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )

    # Check if user is active
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account is disabled"
        )

    # Generate token
    access_token, expires_in = auth_service.create_access_token(
        user_id=user.id,
        email=user.email
    )

    return Token(
        access_token=access_token,
        token_type="bearer",
        expires_in=expires_in,
        user=UserResponse.model_validate(user)
    )


@router.get(
    "/me",
    response_model=UserResponse,
    summary="Get current user",
    description="Get the currently authenticated user's profile"
)
async def get_me(current_user: UserDB = Depends(require_auth)):
    """
    Get current user profile.

    Requires valid JWT token in Authorization header.
    """
    return UserResponse.model_validate(current_user)


@router.post(
    "/logout",
    summary="Logout",
    description="Logout current user (client-side token invalidation)"
)
async def logout():
    """
    Logout endpoint.

    Note: JWT tokens are stateless, so this endpoint just returns success.
    The client should remove the token from local storage.
    """
    return {"message": "Logged out successfully"}
