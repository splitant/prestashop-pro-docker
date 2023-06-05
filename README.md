# Prestashop pro docker

## About The Project

The goal is to set up fastly a local Prestashop project with docker environment for professional uses.

### Built With

* [PrestaShop](https://github.com/PrestaShop/PrestaShop)

### Requirements

* Install [mkcert](https://github.com/FiloSottile/mkcert)

## New project

   ```sh
   git clone git@github.com:splitant/prestashop-pro-docker.git
   cd prestashop-pro-docker
   make create-init <project>
   # Fill env file
   make up
   ```

## Existing project

### Create project directory

   ```sh
   git clone git@github.com:splitant/prestashop-pro-docker.git
   cd prestashop-pro-docker
   make create-init <project>
   ```

### Get project source files into 'project' directory

#### Clone the repository

   ```sh
   git clone <repo.git> ./project
   ```

#### Or rsync from PPRD/PROD env (bad)

   ```sh
   rsync -azvP <user>@<machine_name>:/<path_to_project> ./project
   ```

### Get database dump from PPRD/PROD env

   ```sh
   mysqldump -u"<user>" -h"<db_host>" -p "<db_name>" --single-transaction --create-options --extended-insert --complete-insert --databases --add-drop-database | gzip > dump_$(date +%d%m%Y-%H%M%S).sql.gz

   # Rsync to local
   ```

### Install project

   ```sh   
   # Fill env file
   # set "DISABLE_MAKE=1" if no composer.json

   make up
   
   # Restore dump
   make restore-dump "<dump_filename>.sql.gz"

   # SQL operations domain URL
   make mysql-domain-operations

   # Empty cache : to do in prestashop container
   rm -rf ./var/cache/*

   # Change values in ./project/app/config/parameters.php

   # In /<admin-dev>/index.php/configure/shop/seo-urls
   # 'Configuration des URL' > 'URL simplifiée'
   # Switch 'Oui' to 'Non'
   # Save
   # Switch 'Non' to 'Oui'
   # Save

   # In /admin420dxbxwu/index.php/configure/advanced/performance
   # Click on 'Vider le cache'
   ```

## Make commands

### Connect to Prestashop container

  ```sh
  make shell
  ```

### Reset project

  ```sh
  make prune
  ```