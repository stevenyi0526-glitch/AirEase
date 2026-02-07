# AirEase Backend

AirEase 航班体验优选 - 后端API服务

## 技术栈

- **框架**: FastAPI 0.109
- **Python**: 3.10+
- **AI**: Google Gemini 2.0 Flash
- **航班数据**: Mock / Amadeus API

## 快速开始

### 1. 安装依赖

```bash
cd backend
python -m venv venv
source venv/bin/activate  # macOS/Linux
# 或 .\venv\Scripts\activate  # Windows

pip install -r requirements.txt
```

### 2. 配置环境变量

编辑 `.env` 文件（已预配置）:

```bash
# Gemini API Key（已配置）
GEMINI_API_KEY=...

# Amadeus API（可选，用于真实航班数据）
AMADEUS_API_KEY=your_key
AMADEUS_API_SECRET=your_secret
```

### 3. 启动服务

```bash
# 方式1: 使用 run.py
python run.py

# 方式2: 使用 uvicorn
uvicorn app.main:app --reload --port 8000
```

### 4. 访问API

- **API文档**: http://localhost:8000/docs
- **ReDoc文档**: http://localhost:8000/redoc
- **健康检查**: http://localhost:8000/health

## API 端点

### 航班服务

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | `/v1/flights/search` | 搜索航班 |
| GET | `/v1/flights/{id}` | 获取航班详情 |
| GET | `/v1/flights/{id}/price-history` | 获取价格历史 |

### AI服务

| 方法 | 路径 | 描述 |
|------|------|------|
| POST | `/v1/ai/search` | AI智能搜索 |
| POST | `/v1/ai/explain` | AI评分解释 |
| GET | `/v1/ai/health` | AI服务状态 |

## 请求示例

### 搜索航班

```bash
curl "http://localhost:8000/v1/flights/search?from=北京&to=上海&date=2025-01-15&cabin=economy"
```

### AI智能搜索

```bash
curl -X POST "http://localhost:8000/v1/ai/search" \
  -H "Content-Type: application/json" \
  -d '{"query": "下周三北京到上海的公务舱"}'
```

### 获取航班详情

```bash
curl "http://localhost:8000/v1/flights/flight-1"
```

## 响应格式

### 航班搜索响应

```json
{
  "flights": [
    {
      "flight": {
        "id": "flight-1",
        "flightNumber": "CA1234",
        "airline": "中国国航",
        "departureCity": "北京",
        "arrivalCity": "上海",
        "departureTime": "2025-01-15T08:30:00+08:00",
        "arrivalTime": "2025-01-15T11:00:00+08:00",
        "durationMinutes": 150,
        "price": 1280,
        "cabin": "经济舱"
      },
      "score": {
        "overallScore": 8.5,
        "dimensions": {
          "safety": 9.0,
          "comfort": 8.2,
          "service": 8.0,
          "value": 7.5
        },
        "highlights": ["机上WiFi", "直飞"]
      },
      "facilities": {
        "hasWifi": true,
        "hasPower": true,
        "seatPitchInches": 34,
        "mealIncluded": true
      }
    }
  ],
  "meta": {
    "total": 1,
    "searchId": "search-abc123"
  }
}
```

### AI搜索响应

```json
{
  "parsedQuery": {
    "from": "北京",
    "to": "上海",
    "date": "2025-01-08",
    "cabin": "business"
  },
  "confidence": 0.95,
  "originalQuery": "下周三北京到上海的公务舱",
  "suggestions": []
}
```

## 项目结构

```
backend/
├── .env                    # 环境变量
├── requirements.txt        # Python依赖
├── run.py                  # 启动脚本
├── README.md              # 本文档
└── app/
    ├── __init__.py
    ├── config.py          # 配置管理
    ├── models.py          # Pydantic模型
    ├── main.py            # FastAPI应用
    ├── routes/
    │   ├── __init__.py
    │   ├── flights.py     # 航班API
    │   └── ai.py          # AI搜索API
    └── services/
        ├── __init__.py
        ├── mock_service.py      # Mock数据服务
        ├── gemini_service.py    # Gemini AI服务
        └── amadeus_service.py   # Amadeus真实API
```

## 开发说明

### Mock vs 真实API

默认使用Mock服务生成模拟数据。要使用Amadeus真实API：

1. 在 https://developers.amadeus.com/ 注册账号
2. 获取API Key和Secret
3. 在 `.env` 中配置:
   ```
   AMADEUS_API_KEY=your_api_key
   AMADEUS_API_SECRET=your_api_secret
   ```
4. 修改 `routes/flights.py` 使用 `amadeus_service`

### 添加新航线

编辑 `services/mock_service.py` 中的 `routes` 列表添加新航线。

### 自定义评分算法

修改 `services/mock_service.py` 中的 `_generate_score()` 方法。

## iOS客户端配置

在iOS项目的 `AppConfiguration.swift` 中配置后端地址:

```swift
AppConfiguration.shared.baseURL = "http://localhost:8000"
AppConfiguration.shared.useMockData = false  // 使用后端API
```

## 许可证

MIT License
