.PHONY: up
up:
	docker-compose up

.PHONY: down
down:
	docker-compose down

.PHONY: rebuild
rebuild: setup
	docker-compose up

.PHONY: test
test: rspec

.PHONY: rspec
rspec:
	docker-compose run web bin/rspec

.PHONY: console
console:
	docker-compose run web bin/rails console

.PHONY: setup
setup:
	docker-compose build
	docker-compose run web bin/rails db:setup
