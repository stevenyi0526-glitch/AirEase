"""
AirEase Backend - Mock Data Service
模拟航班数据服务
"""

from datetime import datetime, timedelta
from typing import List, Optional
import random
import uuid

from app.models import (
    Flight, FlightScore, FlightFacilities, FlightWithScore,
    FlightDetail, PriceHistory, PricePoint, PriceTrend,
    ScoreDimensions, ScoreExplanation
)


class MockFlightService:
    """Mock航班数据服务"""
    
    def __init__(self):
        self._flights: List[FlightWithScore] = []
        self._generate_mock_flights()
    
    def _generate_mock_flights(self):
        """生成模拟航班数据"""
        airlines = [
            ("CA", "中国国航"),
            ("MU", "东方航空"),
            ("CZ", "南方航空"),
            ("HU", "海南航空"),
            ("3U", "四川航空"),
            ("ZH", "深圳航空"),
            ("FM", "上海航空"),
            ("MF", "厦门航空"),
        ]
        
        routes = [
            ("北京", "PEK", "首都国际机场", "上海", "SHA", "虹桥国际机场"),
            ("北京", "PEK", "首都国际机场", "上海", "PVG", "浦东国际机场"),
            ("上海", "SHA", "虹桥国际机场", "北京", "PEK", "首都国际机场"),
            ("广州", "CAN", "白云国际机场", "北京", "PEK", "首都国际机场"),
            ("深圳", "SZX", "宝安国际机场", "上海", "SHA", "虹桥国际机场"),
            ("成都", "TFU", "天府国际机场", "北京", "PEK", "首都国际机场"),
            ("杭州", "HGH", "萧山国际机场", "北京", "PEK", "首都国际机场"),
            ("武汉", "WUH", "天河国际机场", "上海", "SHA", "虹桥国际机场"),
        ]
        
        cabins = ["经济舱", "公务舱", "头等舱"]
        aircrafts = [
            "Boeing 787-9", "Boeing 737-800", "Boeing 777-300",
            "Airbus A320", "Airbus A330", "Airbus A350", "Airbus A321"
        ]
        
        flight_id = 1
        base_date = datetime.now() + timedelta(days=3)
        
        for route in routes:
            from_city, from_code, from_airport, to_city, to_code, to_airport = route
            
            for _ in range(random.randint(3, 6)):
                airline_code, airline_name = random.choice(airlines)
                flight_number = f"{airline_code}{random.randint(1000, 9999)}"
                
                hour = random.randint(6, 21)
                minute = random.choice([0, 15, 30, 45])
                departure_time = base_date.replace(hour=hour, minute=minute, second=0, microsecond=0)
                
                duration = random.randint(120, 200)
                arrival_time = departure_time + timedelta(minutes=duration)
                
                cabin = random.choice(cabins)
                base_price = {
                    "经济舱": random.randint(800, 1500),
                    "公务舱": random.randint(2500, 4500),
                    "头等舱": random.randint(5000, 8000)
                }[cabin]
                
                stops = random.choices([0, 1], weights=[85, 15])[0]
                
                flight = Flight(
                    id=f"flight-{flight_id}",
                    flightNumber=flight_number,
                    airline=airline_name,
                    airlineCode=airline_code,
                    departureCity=from_city,
                    departureCityCode=from_code,
                    departureAirport=from_airport,
                    departureAirportCode=from_code,
                    departureTime=departure_time,
                    arrivalCity=to_city,
                    arrivalCityCode=to_code,
                    arrivalAirport=to_airport,
                    arrivalAirportCode=to_code,
                    arrivalTime=arrival_time,
                    durationMinutes=duration,
                    stops=stops,
                    stopCities=["武汉"] if stops > 0 else None,
                    cabin=cabin,
                    aircraftModel=random.choice(aircrafts),
                    price=float(base_price),
                    currency="CNY",
                    seatsRemaining=random.randint(1, 50)
                )
                
                score = self._generate_score(flight)
                facilities = self._generate_facilities(cabin)
                
                self._flights.append(FlightWithScore(
                    flight=flight,
                    score=score,
                    facilities=facilities
                ))
                
                flight_id += 1
    
    def _generate_score(self, flight: Flight) -> FlightScore:
        """生成航班评分"""
        safety = round(random.uniform(7.5, 9.5), 1)
        comfort = round(random.uniform(6.0, 9.0), 1)
        service = round(random.uniform(6.5, 9.0), 1)
        value = round(random.uniform(6.0, 9.5), 1)
        
        overall = round((safety * 0.25 + comfort * 0.3 + service * 0.2 + value * 0.25), 1)
        
        highlights = []
        if comfort > 8.0:
            highlights.append("宽敞座椅")
        if value > 8.0:
            highlights.append("高性价比")
        if flight.stops == 0:
            highlights.append("直飞")
        if random.random() > 0.5:
            highlights.append("机上WiFi")
        
        explanations = [
            ScoreExplanation(
                dimension="safety",
                title="航司安全记录",
                detail=f"{flight.airline}拥有良好的安全飞行记录",
                isPositive=True
            ),
            ScoreExplanation(
                dimension="comfort",
                title="座椅空间",
                detail=f"座椅间距{random.randint(30, 36)}英寸",
                isPositive=comfort > 7.5
            ),
            ScoreExplanation(
                dimension="service",
                title="机上服务",
                detail="提供餐食和饮品服务",
                isPositive=True
            ),
            ScoreExplanation(
                dimension="value",
                title="价格评估",
                detail=f"当前价格{'低于' if value > 7.5 else '接近'}该航线平均水平",
                isPositive=value > 7.5
            )
        ]
        
        return FlightScore(
            overallScore=overall,
            dimensions=ScoreDimensions(
                safety=safety,
                comfort=comfort,
                service=service,
                value=value
            ),
            highlights=highlights[:3],
            explanations=explanations,
            personaWeightsApplied="default"
        )
    
    def _generate_facilities(self, cabin: str) -> FlightFacilities:
        """生成机上设施"""
        is_premium = cabin in ["公务舱", "头等舱"]
        
        return FlightFacilities(
            hasWifi=random.choice([True, False, None]),
            hasPower=random.choice([True, False]) if not is_premium else True,
            seatPitchInches=random.randint(30, 34) if cabin == "经济舱" else random.randint(38, 78),
            seatPitchCategory="宽敞" if is_premium else random.choice(["标准", "紧凑", "宽敞"]),
            hasIFE=random.choice([True, False]) if not is_premium else True,
            ifeType="个人屏幕" if is_premium or random.random() > 0.5 else None,
            mealIncluded=True,
            mealType="公务舱餐食" if is_premium else random.choice(["正餐", "轻食"])
        )
    
    def _generate_price_history(self, flight: Flight) -> PriceHistory:
        """生成价格历史"""
        points = []
        base_date = datetime.now()
        trend = random.choice([PriceTrend.RISING, PriceTrend.FALLING, PriceTrend.STABLE])
        
        for i in range(7, 0, -1):
            date = base_date - timedelta(days=i)
            if trend == PriceTrend.RISING:
                variation = (7 - i) * random.uniform(15, 25)
            elif trend == PriceTrend.FALLING:
                variation = -(7 - i) * random.uniform(15, 25)
            else:
                variation = random.uniform(-30, 30)
            
            price = max(flight.price + variation, flight.price * 0.7)
            points.append(PricePoint(
                date=date.strftime("%Y-%m-%d"),
                price=round(price, 0)
            ))
        
        return PriceHistory(
            flightId=flight.id,
            points=points,
            currentPrice=flight.price,
            trend=trend
        )
    
    # ============================================================
    # Public API
    # ============================================================
    
    def search_flights(
        self,
        from_city: str,
        to_city: str,
        date: str,
        cabin: str = "economy"
    ) -> List[FlightWithScore]:
        """搜索航班"""
        cabin_map = {
            "economy": "经济舱",
            "business": "公务舱",
            "first": "头等舱",
            "经济舱": "经济舱",
            "公务舱": "公务舱",
            "头等舱": "头等舱"
        }
        target_cabin = cabin_map.get(cabin, "经济舱")
        
        results = []
        for fws in self._flights:
            flight = fws.flight
            
            # 匹配城市
            from_match = (
                from_city in flight.departure_city or
                from_city == flight.departure_city_code
            )
            to_match = (
                to_city in flight.arrival_city or
                to_city == flight.arrival_city_code
            )
            cabin_match = flight.cabin == target_cabin
            
            if from_match and to_match and cabin_match:
                results.append(fws)
        
        return results
    
    def get_flight_detail(self, flight_id: str) -> Optional[FlightDetail]:
        """获取航班详情"""
        for fws in self._flights:
            if fws.flight.id == flight_id:
                return FlightDetail(
                    flight=fws.flight,
                    score=fws.score,
                    facilities=fws.facilities,
                    priceHistory=self._generate_price_history(fws.flight)
                )
        return None
    
    def get_price_history(self, flight_id: str) -> Optional[PriceHistory]:
        """获取价格历史"""
        for fws in self._flights:
            if fws.flight.id == flight_id:
                return self._generate_price_history(fws.flight)
        return None


# Singleton instance
mock_flight_service = MockFlightService()
