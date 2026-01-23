# AirEase 航班体验优选

## 项目简介

AirEase 是一款 iOS 航班体验评分应用，帮助用户找到最适合自己出行需求的航班。应用基于用户画像（商务/亲子/学生）提供个性化的航班评分和推荐。

## 技术栈

### iOS 客户端
- **语言**: Swift 5.9+
- **UI框架**: SwiftUI
- **架构**: MVVM (Model-View-ViewModel)
- **图表**: Swift Charts (价格趋势) + SwiftUI Canvas (雷达图)
- **网络**: async/await
- **持久化**: AppStorage/UserDefaults
- **AI**: Google Gemini 2.0 Flash (智能搜索)

### 后端服务
- **框架**: FastAPI 0.109 (Python)
- **AI**: Google Gemini 2.0 Flash
- **航班数据**: Mock / Amadeus API
- **文档**: OpenAPI (Swagger)

## 项目结构

```
AirEase/
├── .env                                 # 环境变量（API密钥）- 不要提交到Git
├── backend/                             # 🆕 后端API服务
│   ├── app/
│   │   ├── main.py                      # FastAPI应用入口
│   │   ├── config.py                    # 配置管理
│   │   ├── models.py                    # Pydantic数据模型
│   │   ├── routes/                      # API路由
│   │   │   ├── flights.py               # 航班搜索/详情API
│   │   │   └── ai.py                    # AI智能搜索API
│   │   └── services/                    # 业务服务
│   │       ├── mock_service.py          # Mock数据服务
│   │       ├── gemini_service.py        # Gemini AI服务
│   │       └── amadeus_service.py       # Amadeus真实API
│   ├── tests/                           # API测试
│   ├── requirements.txt                 # Python依赖
│   ├── run.py                           # 启动脚本
│   └── README.md                        # 后端文档
├── AirEase/                             # iOS客户端
│   ├── App/
│   │   └── AppConfiguration.swift       # 应用配置（功能开关）
│   ├── Core/
│   │   ├── Models/                      # 数据模型
│   │   │   ├── Flight.swift             # 航班模型
│   │   │   ├── FlightScore.swift        # 评分模型
│   │   │   ├── FlightFacilities.swift   # 设施模型
│   │   │   ├── FlightDetail.swift       # 详情聚合模型
│   │   │   ├── PriceHistory.swift       # 价格历史模型
│   │   │   ├── SearchQuery.swift        # 搜索查询模型
│   │   │   └── UserPersona.swift        # 用户画像模型
│   │   ├── Services/                    # 服务层
│   │   │   ├── FlightServiceProtocol.swift  # 航班服务协议
│   │   │   ├── MockFlightService.swift  # Mock服务（开发/演示）
│   │   │   ├── RealFlightService.swift  # 真实API服务
│   │   │   ├── PersistenceService.swift # 本地持久化
│   │   │   ├── ScoringService.swift     # 评分计算服务
│   │   │   ├── GeminiService.swift      # Gemini LLM服务
│   │   │   └── Environment.swift        # 环境变量加载
│   │   └── Utilities/
│   │       ├── Constants.swift          # 常量定义
│   │       └── Extensions.swift         # 扩展方法
│   ├── Features/
│   │   ├── Root/
│   │   │   └── RootView.swift           # 根视图（导航控制）
│   │   ├── Splash/
│   │   │   └── SplashView.swift         # 启动画面
│   │   ├── Onboarding/
│   │   │   ├── OnboardingView.swift     # 用户画像选择
│   │   └── OnboardingViewModel.swift
│   ├── Search/
│   │   ├── SearchHomeView.swift         # 搜索首页
│   │   └── SearchHomeViewModel.swift
│   ├── FlightList/
│   │   ├── FlightListView.swift         # 航班列表
│   │   ├── FlightListViewModel.swift
│   │   └── Components/
│   │       └── FlightCardView.swift     # 航班卡片
│   ├── FlightDetail/
│   │   ├── FlightDetailView.swift       # 航班详情
│   │   ├── FlightDetailViewModel.swift
│   │   └── Components/
│   │       ├── RadarChartView.swift     # 雷达图
│   │       ├── ScoreExplanationView.swift
│   │       ├── FacilitiesGridView.swift
│   │       ├── PriceTrendChartView.swift
│   │       └── TimelineView.swift
│   └── Stubs/                           # P2功能占位
│       ├── PKCompareView.swift
│       ├── FavoritesView.swift
│       └── WeChatLoginStub.swift
└── Resources/
    └── MockData/
        └── flights.json                 # Mock航班数据
```

## 功能状态

### P0 - 核心功能 ✅ 已实现
- [x] 用户画像选择（商务/亲子/学生）
- [x] 航班搜索表单
- [x] 最近搜索记录（最多3条）
- [x] 航班列表展示
- [x] AirEase体验分徽章（0-10分，颜色分级）
- [x] 列表排序（体验分/价格/时长）
- [x] 航班详情页
- [x] 雷达图（4维度：安全/舒适/服务/性价比）
- [x] 评分解析（展开/收起）
- [x] 设施信息展示
- [x] 价格走势图
- [x] 行程时间线
- [x] Mock数据切换机制

### P1 - 重要功能 ✅ 已实现
- [x] 启动画面
- [x] **AI智能搜索（Gemini 2.0 Flash）** ✨
- [x] 收藏航班（本地存储）

### P2 - 占位功能
- [ ] 微信登录（UI占位，显示提示）
- [ ] PK对比（占位页面）
- [ ] 价格监控（UI占位，显示提示）

## 运行项目

1. 使用 Xcode 15+ 打开 `AirEase.xcodeproj`
2. 选择目标设备（模拟器或真机）
3. 点击运行 (⌘R)

## 环境变量配置

项目使用 `.env` 文件存储API密钥（已配置好）：

```bash
# .env 文件内容
GEMINI_API_KEY=your_gemini_api_key_here
FLIGHT_API_KEY=your_flight_api_key_here
```

⚠️ **重要**: `.env` 文件已添加到 `.gitignore`，不会被提交到版本控制。

## Mock/真实API切换

在 `AppConfiguration.swift` 中控制：

```swift
// 使用Mock数据（默认）
AppConfiguration.shared.useMockData = true

// 切换到真实API
AppConfiguration.shared.useMockData = false
AppConfiguration.shared.baseURL = "https://your-api-domain.com"
```

---

## 外部API密钥要求

### 1. Google Gemini API（已配置）✅

用于 **AI智能搜索**功能，自然语言解析航班查询。

- **官网**: https://ai.google.dev/
- **模型**: `gemini-2.0-flash-exp`
- **配置位置**: `.env` 文件中的 `GEMINI_API_KEY`

```bash
# .env
GEMINI_API_KEY=AIzaSyCdyS2YsF9CmCuwK4dFhgMrk3sv5dbrH6Q
```

**使用示例**:
- 用户输入: "下周三北京到上海公务舱"
- Gemini解析: `{ fromCity: "北京", toCity: "上海", date: "2025-01-08", cabin: "公务舱" }`

### 2. 航班数据API（生产环境需要）

**推荐选项：**

#### 选项A: Amadeus API（推荐）
- **官网**: https://developers.amadeus.com/
- **免费额度**: 每月2000次调用
- **注册步骤**:
  1. 访问 https://developers.amadeus.com/register
  2. 创建账号并验证邮箱
  3. 创建新应用获取 API Key 和 API Secret

```swift
// AppConfiguration.swift 中配置
config.flightAPIKey = "YOUR_AMADEUS_API_KEY"
config.flightAPISecret = "YOUR_AMADEUS_API_SECRET"
config.baseURL = "https://api.amadeus.com"
```

#### 选项B: Skyscanner API (RapidAPI)
- **官网**: https://rapidapi.com/skyscanner/api/skyscanner-flight-search
- **免费额度**: 每月50次调用（基础版）

#### 选项C: AeroDataBox
- **官网**: https://rapidapi.com/aerodatabox/api/aerodatabox
- **免费额度**: 每月300次调用

#### 选项D: 携程/飞猪开放平台（中国市场）
- 携程开放平台: https://open.ctrip.com/
- 飞猪开放平台: https://open.alitrip.com/

### 2. 微信开放平台（P2可选）

**用途**: 微信OAuth登录

- **官网**: https://open.weixin.qq.com/
- **注册步骤**:
  1. 注册微信开放平台账号
  2. 创建移动应用
  3. 获取 AppID 和 AppSecret
  4. 配置 iOS Universal Links

```swift
// AppConfiguration.swift 中配置
config.weChatAppID = "YOUR_WECHAT_APP_ID"
config.weChatAppSecret = "YOUR_WECHAT_APP_SECRET"
```

### 3. 航司安全评级数据（可选）

**用于增强安全评分的准确性：**

- **AirlineRatings.com API**: https://www.airlineratings.com/api/
- **IATA安全审计数据**: 需企业合作

---

## Mock API响应格式

### 搜索航班响应

```json
{
  "flights": [
    {
      "flight": {
        "id": "string",
        "flightNumber": "CA1234",
        "airline": "中国国航",
        "departureCity": "北京",
        "arrivalCity": "上海",
        "departureTime": "2025-01-15T08:30:00+08:00",
        "arrivalTime": "2025-01-15T11:00:00+08:00",
        "durationMinutes": 150,
        "stops": 0,
        "cabin": "经济舱",
        "aircraftModel": "Boeing 787-9",
        "price": 1280,
        "currency": "CNY"
      },
      "score": {
        "overallScore": 8.5,
        "dimensions": {
          "safety": 9.0,
          "comfort": 8.2,
          "service": 8.0,
          "value": 7.5
        },
        "highlights": ["机上WiFi", "宽敞座椅", "直飞"]
      },
      "facilities": {
        "hasWifi": true,
        "hasPower": true,
        "seatPitchInches": 34,
        "hasIFE": true
      }
    }
  ],
  "meta": {
    "total": 1,
    "searchId": "uuid"
  }
}
```

### 价格历史响应

```json
{
  "flightId": "string",
  "points": [
    {"date": "2025-01-08", "price": 1350},
    {"date": "2025-01-09", "price": 1320}
  ],
  "currentPrice": 1280,
  "trend": "falling"
}
```

---

## 后续开发建议

1. **接入真实航班API**: 优先选择 Amadeus API，免费额度足够MVP测试
2. **实现后端服务**: 使用 FastAPI 或 Node.js 作为中间层
3. **添加缓存层**: Redis 缓存航班搜索结果（TTL 5分钟）
4. **用户系统**: 实现微信登录完整流程
5. **推送通知**: 价格监控功能需要后端支持
6. **数据分析**: 集成统计SDK追踪用户行为

## 许可证

MIT License
