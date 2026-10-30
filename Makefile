COMPOSE = docker compose

.PHONY: help cert build up down restart ps logs config nginx-test

# Menampilkan daftar perintah
help:
	@echo "TNIS-Junior_SE - Available Commands"
	@echo "-----------------------------------"
	@echo "make cert        - Generate SSL certificate"
	@echo "make build       - Build Docker images"
	@echo "make up          - Start containers"
	@echo "make down        - Stop containers"
	@echo "make restart     - Restart containers"
	@echo "make ps          - Check container status"
	@echo "make logs        - View container logs"
	@echo "make config      - Validate Docker Compose"
	@echo "make nginx-test  - Validate Nginx configuration"

# Membuat sertifikat SSL menggunakan mkcert
cert:
	mkdir -p nginx/certs
	mkcert -install
	mkcert -cert-file nginx/certs/tnis.test.crt -key-file nginx/certs/tnis.test.key tnis.test
	chmod 600 nginx/certs/tnis.test.key

# Build Docker images
build:
	$(COMPOSE) build

# Menjalankan container
up:
	$(COMPOSE) up -d

# Menghentikan container tanpa menghapus volume
down:
	$(COMPOSE) down

# Restart container
restart:
	$(COMPOSE) restart

# Melihat status container
ps:
	$(COMPOSE) ps

# Melihat log container
logs:
	$(COMPOSE) logs -f

# Validasi Docker Compose
config:
	$(COMPOSE) config

# Validasi konfigurasi Nginx
nginx-test:
	docker exec tnis-nginx nginx -t
