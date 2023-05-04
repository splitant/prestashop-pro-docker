# Prestashop pro docker

## About The Project

The goal is to set up fastly a local Prestashop project with docker environment for professional uses.

### Built With

* [PrestaShop](https://github.com/PrestaShop/PrestaShop)

## Getting Started

### Requirements

* Install [mkcert](https://github.com/FiloSottile/mkcert)

### Installation

(In progress)

### New project

   ```sh
   make create-init <project>
   cd ../<project>-docker
   make copy-env-file
   # Fill env file
   make up
   ```
### Existing project

   ```sh
   make create-init <project>
   cd ../<project>-docker
   # Get project source files (via 'git' or 'rsync') into 'project' directory
   make copy-env-file
   # Fill env file
   # set "DISABLE_MAKE=1" if no composer.json
   make up
   ```

### Connect to Prestashop container

  ```sh
  make shell
  ```

### Reset project

  ```sh
  make prune
  ```
