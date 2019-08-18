.PHONY: up
up:
	docker-compose up

.PHONY: down
down:
	docker-compose down

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
	docker-compose up --build
	docker-compose run web bin/rails db:setup
