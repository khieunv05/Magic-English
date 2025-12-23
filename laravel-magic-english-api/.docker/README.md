# Start

```sh
docker-compose up --build -d
docker compose up -d --build --force-recreate

--build: buộc build lại image, đảm bảo Dockerfile + COPY + cài đặt mới được áp dụng.
--force-recreate: buộc xóa container cũ rồi tạo lại container mới từ image vừa build, vì vậy entrypoint.sh sẽ chạy lại từ đầu.

docker compose down
docker compose build --no-cache app
docker compose up -d --force-recreate
docker compose exec app bash -lc "php -m | grep -i redis && composer --version"
```

## Ubuntu WSL 22.04.5 LTS
```sh
sudo apt-get update
sudo apt install -y curl ca-certificates build-essential
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"
nvm install --lts
node -v
npm -v
corepack enable
corepack prepare yarn@stable --activate
yarn -v


sudo apt update && sudo apt install -y openssh-client
ssh-keygen -t ed25519 -C "treconyl@gmail.com"
```
