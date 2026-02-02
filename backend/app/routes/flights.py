"""
AirEase Backend - Flight API Routes
航班相关API路由
"""

from fastapi import APIRouter, HTTPException, Query, Header
from typing import Optional
import uuid

from app.models import (
    FlightSearchResponse, FlightDetail, PriceHistory,
    FlightWithScore, SearchMeta, ErrorResponse
)
from app.services.mock_service import mock_flight_service
from app.services.auth_service import auth_service
from app.config import settings

# Maximum number of results for non-authenticated users
MAX_FREE_RESULTS = 3

router = APIRouter(prefix="/v1/flights", tags=["Flights"])


@router.get(
    "/search",
    response_model=FlightSearchResponse,
    summary="搜索航班",
    description="根据出发地、目的地、日期和舱位搜索航班。未登录用户只能看到前3条结果。"
)
async def search_flights(
    from_city: str = Query(..., alias="from", description="出发城市（如：北京、上海）"),
    to_city: str = Query(..., alias="to", description="到达城市"),
    date: str = Query(..., description="出发日期（YYYY-MM-DD）"),
    cabin: str = Query("economy", description="舱位：economy/business/first 或 经济舱/公务舱/头等舱"),
    authorization: Optional[str] = Header(None, description="JWT Bearer token")
):
    """
    搜索航班

    - **from**: 出发城市名称或代码
    - **to**: 到达城市名称或代码
    - **date**: 出发日期，格式 YYYY-MM-DD
    - **cabin**: 舱位类型
    - **Authorization**: Bearer token（可选，未登录用户只能看到前3条结果）

    返回匹配的航班列表，包含评分和设施信息
    """
    try:
        # Check authentication status
        is_authenticated = False
        if authorization and authorization.startswith("Bearer "):
            token = authorization.split(" ")[1]
            payload = auth_service.decode_token(token)
            is_authenticated = payload is not None

        # 使用Mock服务（可切换为Amadeus服务）
        all_flights = mock_flight_service.search_flights(
            from_city=from_city,
            to_city=to_city,
            date=date,
            cabin=cabin
        )

        total_count = len(all_flights)
        restricted_count = 0

        # Limit results for non-authenticated users
        if is_authenticated:
            visible_flights = all_flights
        else:
            visible_flights = all_flights[:MAX_FREE_RESULTS]
            restricted_count = max(0, total_count - MAX_FREE_RESULTS)

        return FlightSearchResponse(
            flights=visible_flights,
            meta=SearchMeta(
                total=total_count,
                searchId=f"search-{uuid.uuid4().hex[:8]}",
                cachedAt=None,
                restrictedCount=restricted_count,
                isAuthenticated=is_authenticated
            )
        )

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.get(
    "/{flight_id}",
    response_model=FlightDetail,
    summary="获取航班详情",
    description="获取指定航班的完整详情，包括评分、设施和价格历史"
)
async def get_flight_detail(flight_id: str):
    """
    获取航班详情
    
    返回航班的完整信息，包括：
    - 基础航班信息
    - AirEase体验评分（4维度）
    - 机上设施详情
    - 7天价格历史
    """
    detail = mock_flight_service.get_flight_detail(flight_id)
    
    if not detail:
        raise HTTPException(status_code=404, detail="航班不存在")
    
    return detail


@router.get(
    "/{flight_id}/price-history",
    response_model=PriceHistory,
    summary="获取价格历史",
    description="获取航班的7天价格走势"
)
async def get_price_history(flight_id: str):
    """
    获取航班价格历史
    
    返回最近7天的价格变化和趋势分析
    """
    history = mock_flight_service.get_price_history(flight_id)
    
    if not history:
        raise HTTPException(status_code=404, detail="航班不存在")
    
    return history
