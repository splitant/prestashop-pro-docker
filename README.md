# Prestashop pro docker

## About The Project

The goal is to set up fastly a local Prestashop project with docker environment for professional uses.

### Built With

* [PrestaShop](https://github.com/PrestaShop/PrestaShop)

## Getting Started

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

### Connect to Prestashop container

  ```sh
  make shell
  ```

### Reset project

  ```sh
  make prune
  ```