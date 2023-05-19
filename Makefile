build:
	docker compose build

migrate:
	docker compose run --rm app /app/bin/migrate

up: migrate
	docker compose up --detach --remove-orphans

down:
	docker compose down --remove-orphans

logs:
	docker compose logs --follow

sync:
	docker compose run --rm app /app/bin/sync
