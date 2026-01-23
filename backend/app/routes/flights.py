"""
AirEase Backend - Flight API Routes
航班相关API路由
"""

from fastapi import APIRouter, HTTPException, Query
from typing import Optional
import uuid

from app.models import (
    FlightSearchResponse, FlightDetail, PriceHistory,
    FlightWithScore, SearchMeta, ErrorResponse
)
from app.services.mock_service import mock_flight_service
from app.config import settings

router = APIRouter(prefix="/v1/flights", tags=["Flights"])


@router.get(
    "/search",
    response_model=FlightSearchResponse,
    summary="搜索航班",
    description="根据出发地、目的地、日期和舱位搜索航班"
)
async def search_flights(
    from_city: str = Query(..., alias="from", description="出发城市（如：北京、上海）"),
    to_city: str = Query(..., alias="to", description="到达城市"),
    date: str = Query(..., description="出发日期（YYYY-MM-DD）"),
    cabin: str = Query("economy", description="舱位：economy/business/first 或 经济舱/公务舱/头等舱")
):
    """
    搜索航班
    
    - **from**: 出发城市名称或代码
    - **to**: 到达城市名称或代码
    - **date**: 出发日期，格式 YYYY-MM-DD
    - **cabin**: 舱位类型
    
    返回匹配的航班列表，包含评分和设施信息
    """
    try:
        # 使用Mock服务（可切换为Amadeus服务）
        flights = mock_flight_service.search_flights(
            from_city=from_city,
            to_city=to_city,
            date=date,
            cabin=cabin
        )
        
        return FlightSearchResponse(
            flights=flights,
            meta=SearchMeta(
                total=len(flights),
                searchId=f"search-{uuid.uuid4().hex[:8]}",
                cachedAt=None
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
