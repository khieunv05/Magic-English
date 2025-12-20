# Laravel bluefocus agency

composer update --prefer-dist --no-dev -o
git reset --hard HEAD && git pull origin main
php artisan ckfinder:download

## Xóa bảng, migrate lại, và seed

php artisan migrate:fresh --seed
php artisan migrate --path=/database/migrations/0001_01_01_000001_create_cache_table.php
php artisan migrate --path=Modules/Pos/Database/Migrations
php artisan migrate --path=database/migrations

## Laravel Socket

php artisan websockets:serve --port=6009
php artisan websocket:restart

## Laravel queue

php artisan queue:work --timeout=120
php artisan queue:restart

## Laravel schedule

php artisan schedule:work
