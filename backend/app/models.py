"""
AirEase Backend - Pydantic Models
数据模型定义
"""

from pydantic import BaseModel, Field, EmailStr
from typing import Optional, List
from datetime import datetime, date
from enum import Enum


# ============================================================
# Enums
# ============================================================

class CabinClass(str, Enum):
    """舱位类型"""
    ECONOMY = "economy"
    ECONOMY_CN = "经济舱"
    BUSINESS = "business"
    BUSINESS_CN = "公务舱"
    FIRST = "first"
    FIRST_CN = "头等舱"


class PriceTrend(str, Enum):
    """价格趋势"""
    RISING = "rising"
    FALLING = "falling"
    STABLE = "stable"


class FacilityStatus(str, Enum):
    """设施状态"""
    AVAILABLE = "available"
    UNAVAILABLE = "unavailable"
    UNKNOWN = "unknown"


# ============================================================
# Flight Models
# ============================================================

class Flight(BaseModel):
    """航班基础信息"""
    id: str
    flight_number: str = Field(alias="flightNumber")
    airline: str
    airline_code: str = Field(alias="airlineCode")
    departure_city: str = Field(alias="departureCity")
    departure_city_code: str = Field(alias="departureCityCode")
    departure_airport: str = Field(alias="departureAirport")
    departure_airport_code: str = Field(alias="departureAirportCode")
    departure_time: datetime = Field(alias="departureTime")
    arrival_city: str = Field(alias="arrivalCity")
    arrival_city_code: str = Field(alias="arrivalCityCode")
    arrival_airport: str = Field(alias="arrivalAirport")
    arrival_airport_code: str = Field(alias="arrivalAirportCode")
    arrival_time: datetime = Field(alias="arrivalTime")
    duration_minutes: int = Field(alias="durationMinutes")
    stops: int = 0
    stop_cities: Optional[List[str]] = Field(default=None, alias="stopCities")
    cabin: str
    aircraft_model: Optional[str] = Field(default=None, alias="aircraftModel")
    price: float
    currency: str = "CNY"
    seats_remaining: Optional[int] = Field(default=None, alias="seatsRemaining")
    
    class Config:
        populate_by_name = True
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }


# ============================================================
# Score Models
# ============================================================

class ScoreDimensions(BaseModel):
    """评分维度"""
    safety: float = Field(ge=0, le=10)
    comfort: float = Field(ge=0, le=10)
    service: float = Field(ge=0, le=10)
    value: float = Field(ge=0, le=10)


class ScoreExplanation(BaseModel):
    """评分解释"""
    dimension: str
    title: str
    detail: str
    is_positive: bool = Field(alias="isPositive")
    
    class Config:
        populate_by_name = True


class FlightScore(BaseModel):
    """航班评分"""
    overall_score: float = Field(alias="overallScore", ge=0, le=10)
    dimensions: ScoreDimensions
    highlights: List[str] = []
    explanations: List[ScoreExplanation] = []
    persona_weights_applied: str = Field(alias="personaWeightsApplied", default="")
    
    class Config:
        populate_by_name = True


# ============================================================
# Facilities Models
# ============================================================

class FlightFacilities(BaseModel):
    """机上设施"""
    has_wifi: Optional[bool] = Field(default=None, alias="hasWifi")
    has_power: Optional[bool] = Field(default=None, alias="hasPower")
    seat_pitch_inches: Optional[int] = Field(default=None, alias="seatPitchInches")
    seat_pitch_category: Optional[str] = Field(default=None, alias="seatPitchCategory")
    has_ife: Optional[bool] = Field(default=None, alias="hasIFE")
    ife_type: Optional[str] = Field(default=None, alias="ifeType")
    meal_included: Optional[bool] = Field(default=None, alias="mealIncluded")
    meal_type: Optional[str] = Field(default=None, alias="mealType")
    
    class Config:
        populate_by_name = True


# ============================================================
# Price History Models
# ============================================================

class PricePoint(BaseModel):
    """价格点"""
    date: str
    price: float


class PriceHistory(BaseModel):
    """价格历史"""
    flight_id: str = Field(alias="flightId")
    points: List[PricePoint]
    current_price: float = Field(alias="currentPrice")
    trend: PriceTrend
    
    class Config:
        populate_by_name = True


# ============================================================
# Combined Models
# ============================================================

class FlightWithScore(BaseModel):
    """航班 + 评分 + 设施"""
    flight: Flight
    score: FlightScore
    facilities: FlightFacilities


class FlightDetail(BaseModel):
    """航班详情（含价格历史）"""
    flight: Flight
    score: FlightScore
    facilities: FlightFacilities
    price_history: PriceHistory = Field(alias="priceHistory")
    
    class Config:
        populate_by_name = True


# ============================================================
# API Request/Response Models
# ============================================================

class SearchQuery(BaseModel):
    """搜索请求"""
    from_city: str = Field(alias="from")
    to_city: str = Field(alias="to")
    date: str
    cabin: str = "economy"
    
    class Config:
        populate_by_name = True


class SearchMeta(BaseModel):
    """搜索元数据"""
    total: int
    search_id: str = Field(alias="searchId")
    cached_at: Optional[datetime] = Field(default=None, alias="cachedAt")
    restricted_count: int = Field(default=0, alias="restrictedCount")
    is_authenticated: bool = Field(default=False, alias="isAuthenticated")

    class Config:
        populate_by_name = True


class FlightSearchResponse(BaseModel):
    """航班搜索响应"""
    flights: List[FlightWithScore]
    meta: SearchMeta


class AISearchRequest(BaseModel):
    """AI搜索请求"""
    query: str
    persona: Optional[str] = None


class AISearchResponse(BaseModel):
    """AI搜索响应"""
    parsed_query: Optional[SearchQuery] = Field(alias="parsedQuery")
    confidence: float
    original_query: str = Field(alias="originalQuery")
    suggestions: List[str] = []
    
    class Config:
        populate_by_name = True


class ErrorResponse(BaseModel):
    """错误响应"""
    error: str
    detail: Optional[str] = None
    code: int


# ============================================================
# User Authentication Models
# ============================================================

class UserBase(BaseModel):
    """User base model"""
    email: EmailStr
    username: str = Field(min_length=3, max_length=50)


class UserCreate(UserBase):
    """User registration request"""
    password: str = Field(min_length=6)


class UserLogin(BaseModel):
    """User login request"""
    email: EmailStr
    password: str


class UserResponse(UserBase):
    """User response (no password)"""
    id: int
    created_at: datetime
    is_active: bool = True

    class Config:
        from_attributes = True


class Token(BaseModel):
    """JWT token response"""
    access_token: str = Field(alias="accessToken")
    token_type: str = Field(default="bearer", alias="tokenType")
    expires_in: int = Field(alias="expiresIn")  # seconds
    user: UserResponse

    class Config:
        populate_by_name = True


class TokenData(BaseModel):
    """Decoded token data"""
    user_id: int
    email: str
    exp: datetime
