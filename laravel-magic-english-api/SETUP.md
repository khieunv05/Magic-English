# Hướng Dẫn Setup Laravel Magic English API

## 📋 Yêu Cầu Hệ Thống

- Docker & Docker Compose
- Git
- Port 8000 (Nginx), 3306 (MariaDB), 6379 (Redis), 8080 (PHPMyAdmin) không bị chiếm dụng

## 🚀 Các Bước Setup

### 1. Clone và Chuẩn Bị File Cấu Hình

```bash
# Di chuyển vào thư mục project
cd /mnt/d/Learning/backend_magicEnglish/laravel-magic-english-api

# Copy file .env.example thành .env
cp .env.example .env
```

### 2. Cấu Hình File .env

Mở file `.env` và cấu hình các biến môi trường. Các giá trị mặc định đã phù hợp với Docker:

```env
# Tên ứng dụng (dùng cho Docker)
APP_NAME=magic-english
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000

# Database (đã cấu hình sẵn cho Docker)
DB_CONNECTION=mariadb
DB_HOST=mariadb
DB_PORT=3306
DB_DATABASE=timtro247
DB_USERNAME=timtro247
DB_PASSWORD=secret

# Redis (đã cấu hình sẵn cho Docker)
REDIS_HOST=redis
REDIS_PORT=6379

# Session & Queue
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis
CACHE_STORE=redis
```

### 3. Tạo File .env Cho Docker Compose

Tạo file `.docker/.env` với nội dung:

```env
COMPOSE_PROJECT_NAME=magic-english
APP_NAME=magic-english
DB_NAME=timtro247
DB_USER=timtro247
DB_PASSWORD=secret
```

### 4. Khởi Động Docker

```bash
# Di chuyển vào thư mục .docker
cd .docker

# Build và khởi động tất cả containers
docker-compose up --build -d

# Hoặc build lại hoàn toàn từ đầu
docker compose up -d --build --force-recreate
```

**Giải thích các options:**
- `--build`: Buộc build lại image, đảm bảo Dockerfile + COPY + cài đặt mới được áp dụng
- `-d`: Chạy ở background
- `--force-recreate`: Buộc xóa container cũ rồi tạo lại container mới

### 5. Kiểm Tra Trạng Thái Containers

```bash
# Xem các containers đang chạy
docker-compose ps

# Xem logs của tất cả services
docker-compose logs -f

# Xem logs của một service cụ thể
docker-compose logs -f app
```

### 6. Setup Laravel (Trong Container)

```bash
# Truy cập vào container app
docker-compose exec app bash

# Trong container, chạy các lệnh sau:

# 1. Generate APP_KEY (đã tự động chạy trong entrypoint.sh)
php artisan key:generate

# 2. Chạy migrations và seeders
php artisan migrate:fresh --seed

# 3. Hoặc chạy migrations cụ thể
php artisan migrate --path=/database/migrations/0001_01_01_000001_create_cache_table.php

# 4. Thoát khỏi container
exit
```

## 🔌 Các Services Đang Chạy

Sau khi setup thành công, bạn có thể truy cập:

| Service | URL | Mô tả |
|---------|-----|-------|
| **Laravel API** | http://localhost:8000 | Backend API |
| **PHPMyAdmin** | http://localhost:8080 | Quản lý database |
| **MariaDB** | localhost:3306 | Database server |
| **Redis** | localhost:6379 | Cache & Queue |

### Thông Tin Đăng Nhập PHPMyAdmin

- **Server:** mariadb
- **Username:** timtro247
- **Password:** secret

## 📦 Cấu Trúc Docker

Project sử dụng các Docker containers sau:

1. **app**: PHP 8.3-FPM với Laravel
   - Extensions: GD, ZIP, PDO MySQL, MBString, PCNTL, FTP, EXIF, Redis
   - Composer đã cài sẵn
   - Auto install vendor khi khởi động

2. **nginx**: Web server (port 8000)
   - Proxy requests đến PHP-FPM

3. **mariadb**: Database (port 3306)
   - Version: 10.7.3
   - Data được lưu trong volume `db_data`

4. **redis**: Cache & Queue (port 6379)
   - Version: Alpine latest

5. **phpmyadmin**: Database GUI (port 8080)

## 🛠️ Các Lệnh Hữu Ích

### Docker Commands

```bash
# Dừng tất cả containers
docker-compose down

# Xóa containers và volumes (dữ liệu sẽ mất)
docker-compose down -v

# Build lại image không dùng cache
docker compose build --no-cache app

# Restart một service cụ thể
docker-compose restart app
docker-compose restart nginx

# Xem resource usage
docker stats
```

### Laravel Commands (Trong Container)

```bash
# Truy cập container
docker-compose exec app bash

# Clear cache
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Queue worker (nếu cần)
php artisan queue:work --timeout=120

# Schedule worker (nếu cần)
php artisan schedule:work

# WebSocket server (nếu cần)
php artisan websockets:serve --port=6009
```

### Composer Commands (Trong Container)

```bash
docker-compose exec app composer install
docker-compose exec app composer update
docker-compose exec app composer dump-autoload -o
```

## 🐛 Troubleshooting

### Container không khởi động được

```bash
# Xem logs để debug
docker-compose logs app

# Build lại hoàn toàn
docker-compose down
docker compose build --no-cache
docker compose up -d --force-recreate
```

### Permission denied errors

```bash
# Từ bên ngoài container
docker-compose exec app chown -R www-data:www-data storage bootstrap/cache
docker-compose exec app chmod -R 775 storage bootstrap/cache
```

### Database connection failed

```bash
# Kiểm tra MariaDB đã sẵn sàng chưa
docker-compose exec mariadb mariadb-admin ping -h 127.0.0.1

# Kiểm tra credentials trong .env có khớp với .docker/.env không
```

### Port đã bị sử dụng

```bash
# Kiểm tra port đang được sử dụng
sudo netstat -tulpn | grep :8000
sudo netstat -tulpn | grep :3306

# Thay đổi port trong docker-compose.yml nếu cần
```

## 📚 Tài Liệu Tham Khảo

- [Laravel Documentation](https://laravel.com/docs)
- [Docker Documentation](https://docs.docker.com)
- README.md chính của project: [/README.md](README.md)
- README.md Docker: [/.docker/README.md](.docker/README.md)

## ✅ Kiểm Tra Setup Thành Công

1. Truy cập http://localhost:8000 - Bạn sẽ thấy trang Laravel
2. Truy cập http://localhost:8080 - PHPMyAdmin mở được và login thành công
3. Trong container: `php artisan migrate:status` - Hiển thị các migrations đã chạy

## 🔄 Quy Trình Development

### Khởi động lại sau khi tắt máy

```bash
cd .docker
docker-compose up -d
```

### Khi có thay đổi code

- Code PHP thay đổi tự động (do volume mount)
- Nếu thêm package mới: `docker-compose exec app composer install`
- Nếu thêm migration mới: `docker-compose exec app php artisan migrate`

### Khi cần rebuild

```bash
# Nếu thay đổi Dockerfile hoặc file cấu hình Docker
docker-compose up -d --build --force-recreate
```

---

**Lưu ý:** File này tổng hợp từ các README và cấu hình Docker có sẵn trong project. Đảm bảo đọc kỹ các file cấu hình để hiểu rõ hơn về setup.
