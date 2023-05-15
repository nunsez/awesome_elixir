build:
	docker compose build

migrate:
	docker compose run --rm app /app/bin/migrate

start: migrate
	docker-compose run --rm app /app/bin/server
