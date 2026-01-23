"""
AirEase Backend - Amadeus Flight API Service
真实航班数据服务（Amadeus API）
"""

import httpx
from datetime import datetime, timedelta
from typing import List, Optional, Dict, Any

from app.config import settings
from app.models import (
    Flight, FlightScore, FlightFacilities, FlightWithScore,
    FlightDetail, PriceHistory, ScoreDimensions, ScoreExplanation
)


class AmadeusService:
    """
    Amadeus Flight API 服务
    
    文档: https://developers.amadeus.com/
    需要配置 AMADEUS_API_KEY 和 AMADEUS_API_SECRET
    """
    
    def __init__(self):
        self.base_url = settings.amadeus_base_url
        self.api_key = settings.amadeus_api_key
        self.api_secret = settings.amadeus_api_secret
        self.access_token: Optional[str] = None
        self.token_expires: Optional[datetime] = None
        self.client = httpx.AsyncClient(timeout=30.0)
    
    async def _get_access_token(self) -> str:
        """获取OAuth2 Access Token"""
        if self.access_token and self.token_expires and datetime.now() < self.token_expires:
            return self.access_token
        
        auth_url = f"{self.base_url}/v1/security/oauth2/token"
        
        response = await self.client.post(
            auth_url,
            data={
                "grant_type": "client_credentials",
                "client_id": self.api_key,
                "client_secret": self.api_secret
            },
            headers={"Content-Type": "application/x-www-form-urlencoded"}
        )
        
        if response.status_code != 200:
            raise Exception(f"Amadeus auth failed: {response.text}")
        
        data = response.json()
        self.access_token = data["access_token"]
        self.token_expires = datetime.now() + timedelta(seconds=data["expires_in"] - 60)
        
        return self.access_token
    
    async def search_flights(
        self,
        from_city: str,
        to_city: str,
        date: str,
        cabin: str = "ECONOMY"
    ) -> List[FlightWithScore]:
        """
        搜索航班
        
        使用 Amadeus Flight Offers Search API
        """
        token = await self._get_access_token()
        
        # 城市代码映射
        city_codes = {
            "北京": "PEK", "上海": "SHA", "广州": "CAN",
            "深圳": "SZX", "成都": "CTU", "杭州": "HGH",
            "武汉": "WUH", "西安": "XIY", "南京": "NKG"
        }
        
        origin = city_codes.get(from_city, from_city)
        destination = city_codes.get(to_city, to_city)
        
        cabin_map = {
            "economy": "ECONOMY", "经济舱": "ECONOMY",
            "business": "BUSINESS", "公务舱": "BUSINESS",
            "first": "FIRST", "头等舱": "FIRST"
        }
        travel_class = cabin_map.get(cabin.lower(), "ECONOMY")
        
        search_url = f"{self.base_url}/v2/shopping/flight-offers"
        
        params = {
            "originLocationCode": origin,
            "destinationLocationCode": destination,
            "departureDate": date,
            "adults": 1,
            "travelClass": travel_class,
            "currencyCode": "CNY",
            "max": 20
        }
        
        response = await self.client.get(
            search_url,
            params=params,
            headers={
                "Authorization": f"Bearer {token}",
                "Accept": "application/json"
            }
        )
        
        if response.status_code != 200:
            print(f"Amadeus search error: {response.text}")
            return []
        
        data = response.json()
        return self._transform_amadeus_response(data, from_city, to_city, cabin)
    
    def _transform_amadeus_response(
        self,
        data: Dict[str, Any],
        from_city: str,
        to_city: str,
        cabin: str
    ) -> List[FlightWithScore]:
        """转换Amadeus响应为内部格式"""
        results = []
        
        for i, offer in enumerate(data.get("data", [])):
            try:
                segment = offer["itineraries"][0]["segments"][0]
                price = float(offer["price"]["total"])
                
                departure_dt = datetime.fromisoformat(segment["departure"]["at"].replace("Z", "+00:00"))
                arrival_dt = datetime.fromisoformat(segment["arrival"]["at"].replace("Z", "+00:00"))
                duration_minutes = int((arrival_dt - departure_dt).total_seconds() / 60)
                
                flight = Flight(
                    id=f"amadeus-{offer['id']}",
                    flightNumber=f"{segment['carrierCode']}{segment['number']}",
                    airline=segment.get("carrierCode", "Unknown"),
                    airlineCode=segment["carrierCode"],
                    departureCity=from_city,
                    departureCityCode=segment["departure"]["iataCode"],
                    departureAirport=segment["departure"]["iataCode"],
                    departureAirportCode=segment["departure"]["iataCode"],
                    departureTime=departure_dt,
                    arrivalCity=to_city,
                    arrivalCityCode=segment["arrival"]["iataCode"],
                    arrivalAirport=segment["arrival"]["iataCode"],
                    arrivalAirportCode=segment["arrival"]["iataCode"],
                    arrivalTime=arrival_dt,
                    durationMinutes=duration_minutes,
                    stops=len(offer["itineraries"][0]["segments"]) - 1,
                    cabin=cabin,
                    aircraftModel=segment.get("aircraft", {}).get("code"),
                    price=price,
                    currency="CNY",
                    seatsRemaining=offer.get("numberOfBookableSeats")
                )
                
                score = self._generate_score(flight)
                facilities = self._generate_facilities(cabin)
                
                results.append(FlightWithScore(
                    flight=flight,
                    score=score,
                    facilities=facilities
                ))
                
            except Exception as e:
                print(f"Error transforming offer: {e}")
                continue
        
        return results
    
    def _generate_score(self, flight: Flight) -> FlightScore:
        """基于航班属性生成评分"""
        # 简化评分逻辑
        safety = 8.5
        comfort = 7.5 if flight.cabin == "经济舱" else 8.5
        service = 7.5
        value = min(9.0, max(5.0, 10 - (flight.price / 500)))
        
        overall = round((safety * 0.25 + comfort * 0.3 + service * 0.2 + value * 0.25), 1)
        
        return FlightScore(
            overallScore=overall,
            dimensions=ScoreDimensions(
                safety=safety,
                comfort=comfort,
                service=service,
                value=value
            ),
            highlights=["直飞" if flight.stops == 0 else ""],
            explanations=[],
            personaWeightsApplied="default"
        )
    
    def _generate_facilities(self, cabin: str) -> FlightFacilities:
        """生成设施信息（Amadeus API不提供）"""
        is_premium = cabin in ["公务舱", "头等舱", "business", "first"]
        
        return FlightFacilities(
            hasWifi=None,
            hasPower=is_premium,
            seatPitchInches=32 if cabin in ["经济舱", "economy"] else 42,
            seatPitchCategory="标准",
            hasIFE=is_premium,
            ifeType="个人屏幕" if is_premium else None,
            mealIncluded=True,
            mealType="正餐"
        )
    
    async def close(self):
        """关闭HTTP客户端"""
        await self.client.aclose()


# Singleton instance
amadeus_service = AmadeusService()
