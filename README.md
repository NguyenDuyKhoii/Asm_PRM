# 🚗 AutoWash Pro - Hệ thống đặt lịch rửa xe thông minh

## 📋 Mô tả dự án

AutoWash Pro là hệ thống quản lý rửa xe tự động thông minh, tập trung vào **Loyalty** (khách hàng thân thiết) và **Advance Booking** (đặt lịch trước). Ứng dụng mobile cho phép khách hàng đặt lịch rửa xe với logic phân quyền theo hạng thành viên (Tier-based).

## 🏗️ Kiến trúc

### Backend - .NET 9 Clean Architecture
```
AutoWashPro/
├── AutoWashPro.Domain         # Entities, Enums, Business Rules
├── AutoWashPro.Application    # DTOs, Interfaces, Common
├── AutoWashPro.Infrastructure # EF Core + PostgreSQL, JWT, BCrypt
└── AutoWashPro.API            # Controllers, Swagger, Middleware
```

### Frontend - Flutter Clean Architecture
```
autowash_pro/
├── core/          # Theme, Constants
├── data/          # Models, API Service
└── presentation/  # Providers, Screens, Widgets
```

## 🔑 Tính năng chính (Luồng 1 - Tier-based Booking)

### Đăng ký & Đăng nhập
- JWT Authentication với BCrypt password hashing
- Persistent session với SharedPreferences

### Đặt lịch rửa xe theo hạng thành viên
- **Member**: Đặt trước tối đa **7 ngày**
- **Silver**: Đặt trước tối đa **10 ngày** + giảm 5%
- **Gold**: Đặt trước tối đa **12 ngày** + giảm 10%
- **Platinum**: Đặt trước tối đa **14 ngày** + giảm 15%

### Luồng đặt lịch (Happy Path)
1. 📋 **Chọn dịch vụ** - 5 gói từ cơ bản (50k) đến cao cấp (500k)
2. 📅 **Chọn ngày/giờ** - Calendar với ngày bị disable theo tier
3. 🚗 **Chọn xe** - Xe đã đăng ký biển số
4. 📝 **Xem tóm tắt** - Auto-apply ưu đãi theo hạng
5. ✅ **Xác nhận** - Nhận QR Code để check-in tại trạm

### Quản lý xe
- Thêm/xóa xe với biển số và loại xe (ô tô/xe máy)

## 🛠️ Tech Stack

| Thành phần | Công nghệ |
|------------|-----------|
| Backend | .NET 9, Entity Framework Core 9 |
| Database | PostgreSQL (Code First) |
| Auth | JWT + BCrypt |
| Frontend | Flutter 3.44, Dart 3.12 |
| State Management | Provider |
| UI | Google Fonts, flutter_animate, table_calendar, qr_flutter |

## 🚀 Cách chạy

### Yêu cầu
- .NET 9 SDK
- PostgreSQL (localhost:5432)
- Flutter SDK 3.x

### Backend
```bash
cd be/AutoWashPro/src/AutoWashPro.API

# Cấu hình PostgreSQL trong appsettings.json nếu cần
dotnet run
# → http://localhost:5000
# → Swagger: http://localhost:5000/swagger
```

### Frontend
```bash
cd fe/autowash_pro

flutter pub get
flutter run
```

> **Lưu ý**: Nếu chạy trên thiết bị thật, đổi `baseUrl` trong `lib/core/constants/api_constants.dart` thành IP máy chủ backend.

## 👤 Tài khoản demo

| Email | Mật khẩu | Hạng | Điểm | Xe |
|-------|-----------|------|------|-----|
| demo@autowash.com | Demo@123 | Platinum | 500 | 51A-123.45 |
| member@autowash.com | Member@123 | Member | 50 | 59B-678.90 |

## 📡 API Endpoints

| Method | Endpoint | Auth | Mô tả |
|--------|----------|------|--------|
| POST | /api/auth/register | ❌ | Đăng ký |
| POST | /api/auth/login | ❌ | Đăng nhập |
| GET | /api/services | ❌ | Danh sách dịch vụ |
| GET | /api/users/tier | ✅ | Thông tin tier |
| GET | /api/vehicles | ✅ | Xe của tôi |
| POST | /api/vehicles | ✅ | Thêm xe |
| GET | /api/bookings/available-slots | ✅ | Khung giờ trống |
| POST | /api/bookings/summary | ✅ | Preview đơn |
| POST | /api/bookings | ✅ | Tạo booking |
| GET | /api/bookings/my | ✅ | Lịch sử booking |
| PUT | /api/bookings/{id}/cancel | ✅ | Hủy booking |

## 📐 Database Schema (ERD)

```
Users (1) ──── (N) Vehicles
Users (1) ──── (N) Bookings
Services (1) ── (N) Bookings
Vehicles (1) ── (N) Bookings
TimeSlots (1) ─ (N) Bookings
```

## ✅ Kết quả kiểm tra

- ✅ Backend build thành công (0 errors, 0 warnings)
- ✅ Flutter analyze passed (0 errors)
- ✅ Clean Architecture 4 layers
- ✅ Code First với PostgreSQL
- ✅ JWT Authentication
- ✅ Tier-based booking logic
- ✅ Auto-apply perks
- ✅ QR Code generation
