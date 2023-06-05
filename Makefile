include .env

default: help

DESKTOP_PATH ?= ~/Desktop/

## help	:	Print commands help.
.PHONY: help
ifneq (,$(wildcard docker.mk))
help : docker.mk
	@sed -n 's/^##//p' $<
else
help : Makefile
	@sed -n 's/^##//p' $<
endif

## up	:	Start up containers.
.PHONY: up
up:
	@echo "Starting up containers for $(PROJECT_NAME)..."
	mkdir -p project
	$(MAKE) generate-ssl-ca
	docker-compose pull
	docker-compose up --remove-orphans --build

## down	:	Stop containers.
.PHONY: down
down: stop

## start	:	Start containers without updating.
.PHONY: start
start:
	@echo "Starting containers for $(PROJECT_NAME) from where you left off..."
	@docker-compose start

## stop	:	Stop containers.
.PHONY: stop
stop:
	@echo "Stopping containers for $(PROJECT_NAME)..."
	@docker-compose stop

## prune	:	Remove containers and their volumes.
##		You can optionally pass an argument with the service name to prune single container
##		prune mariadb	: Prune `mariadb` container and remove its volumes.
##		prune mariadb solr	: Prune `mariadb` and `solr` containers and remove their volumes.
.PHONY: prune
prune:
	rm -rf project
	@echo "Removing containers for $(PROJECT_NAME)..."
	@docker-compose down -v $(filter-out $@,$(MAKECMDGOALS))

## ps	:	List running containers.
.PHONY: ps
ps:
	@docker ps --filter name='$(PROJECT_NAME)*'

## shell	:	Access `prestashop` container via shell.
##		You can optionally pass an argument with a service name to open a shell on the specified container
.PHONY: shell
shell:
	docker exec -u www-data -ti -e COLUMNS=$(shell tput cols) -e LINES=$(shell tput lines) $(shell docker ps --filter name='$(PROJECT_NAME)_$(or $(filter-out $@,$(MAKECMDGOALS)), 'prestashop')' --format "{{ .ID }}") bash

.PHONY: shell-root
shell-root:
	docker exec -ti -e COLUMNS=$(shell tput cols) -e LINES=$(shell tput lines) $(shell docker ps --filter name='$(PROJECT_NAME)_$(or $(filter-out $@,$(MAKECMDGOALS)), 'prestashop')' --format "{{ .ID }}") bash

## logs	:	View containers logs.
##		You can optinally pass an argument with the service name to limit logs
##		logs php	: View `php` container logs.
##		logs nginx php	: View `nginx` and `php` containers logs.
.PHONY: logs
logs:
	@docker-compose logs -f $(filter-out $@,$(MAKECMDGOALS))

.PHONY: create-init
create-init:
## create-init	:	Creates folder project.
##		For example: make create-init "<project_name>"
	mv ${DESKTOP_PATH}prestashop-pro-docker ${DESKTOP_PATH}$(word 2, $(MAKECMDGOALS))-docker
	mkdir ${DESKTOP_PATH}$(word 2, $(MAKECMDGOALS))-docker/project
	$(MAKE) copy-env-file

.PHONY: copy-env-file
copy-env-file:
## copy-env-file	:	Creates .env file.
	cp .env.dist .env

.PHONY: generate-ssl-ca
generate-ssl-ca:
## generate-ssl-ca	:	Generates SSL certificates.
	mkdir -p .docker/certs
	mkcert -install
	mkcert -cert-file .docker/certs/localhost.pem -key-file .docker/certs/localhost-key.pem localhost

.PHONY: create-dump
create-dump:
## create-dump	:	Creates gzip BDD dump.
	docker exec -u www-data -i $(shell docker ps --filter name='^/$(PROJECT_NAME)_prestashop' --format "{{ .ID }}") mysqldump -u"$(DB_USER)" -p"$(DB_PASSWORD)" -h"$(PROJECT_NAME)_$(DB_HOST)" "$(DB_NAME)" --single-transaction --create-options --extended-insert --complete-insert --databases --add-drop-database | docker exec -u www-data -i $(shell docker ps --filter name='^/$(PROJECT_NAME)_prestashop' --format "{{ .ID }}") sh -c 'gzip > dump_$(shell date +%d%m%Y-%H%M%S).sql.gz'

.PHONY: restore-dump
restore-dump:
## restore-dump	:	Creates gzip BDD dump.
##		For example: make restore-dump "<dump_filename>.sql.gz"
	docker exec -u www-data -i $(shell docker ps --filter name='^/$(PROJECT_NAME)_prestashop' --format "{{ .ID }}") zcat $(filter-out $@,$(MAKECMDGOALS)) | docker exec -u www-data -i $(shell docker ps --filter name='^/$(PROJECT_NAME)_prestashop' --format "{{ .ID }}") mysql -u"$(DB_USER)" -p"$(DB_PASSWORD)" -h"$(PROJECT_NAME)_$(DB_HOST)" "$(DB_NAME)"

.PHONY: mysql-query
mysql-query:
## mysql-query	:	Executes mysql query.
##		For example: make mysql-query "SHOW DATABASES;"
	docker exec -u www-data -i $(shell docker ps --filter name='^/$(PROJECT_NAME)_prestashop' --format "{{ .ID }}") mysql -u"$(DB_USER)" -p"$(DB_PASSWORD)" -h"$(PROJECT_NAME)_$(DB_HOST)" "$(DB_NAME)" -e '$(filter-out $@,$(MAKECMDGOALS))'

.PHONY: mysql-domain-operations
mysql-domain-operations:
## mysql-domain-operations	:	Executes mysql queries operations to update domain URL.
	$(MAKE) mysql-query 'UPDATE $(DB_PREFIX)configuration SET value = "$(PROJECT_BASE_URL):$(PROJECT_PORT)" WHERE name = "PS_SHOP_DOMAIN";'
	$(MAKE) mysql-query 'UPDATE $(DB_PREFIX)configuration SET value = "$(PROJECT_BASE_URL):$(PROJECT_PORT)" WHERE name = "PS_SHOP_DOMAIN_SSL";'
	$(MAKE) mysql-query 'UPDATE $(DB_PREFIX)configuration SET value = "[\"https:\\/\\/$(PROJECT_BASE_URL):$(PROJECT_PORT)\"]" WHERE name = "SC_CORS_DOMAINS";'
	$(MAKE) mysql-query 'UPDATE $(DB_PREFIX)shop_url SET domain = "$(PROJECT_BASE_URL):$(PROJECT_PORT)", domain_ssl = "$(PROJECT_BASE_URL):$(PROJECT_PORT)";'

# https://stackoverflow.com/a/6273809/1826109
%:
	@:
