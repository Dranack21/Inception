
all:up

up: setup check-env
	docker compose -f srcs/docker-compose.yml up -d --build

down:
	docker compose -f srcs/docker-compose.yml down

clean:
	rm -rf /home/habouda42/data/mariadb/
	rm -rf /home/habouda42/data/wordpress/
	docker compose -f srcs/docker-compose.yml down -v
	rm -rf srcs/.env

re: clean up

ENV_FILE ?= /home/.env
LOCAL_ENV = srcs/.env

check-env:
	@if [ ! -f "$(ENV_FILE)" ]; then \
		echo "❌ Error: Environment file not found at $(ENV_FILE)"; \
		exit 1; \
	fi
	@echo "✅ Found $(ENV_FILE), copying to project..."
	@cp $(ENV_FILE) $(LOCAL_ENV)

setup:
	mkdir -p /home/habouda42/data/mariadb
	mkdir -p /home/habouda42/data/wordpress

logs:
	docker compose -f srcs/docker-compose.yml logs -f