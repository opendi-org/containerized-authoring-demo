# Containerized CDD Authoring Demo

This project defines a Docker Container setup that will create a set of services which can be run locally or distributed, to enhance the [OpenDI CDD Authoring Tool](https://opendi.org/cdd-authoring-tool/) with basic data persistence.  
This allows users to perform basic [CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) operations on models they create with this tool. When run locally, these models are saved locally in a SQLite database file within the defined Docker volume.

The services in this project interoperate via compliance with these OpenDI Interoperability Standards:
- [OpenDI API Specification](https://opendi.org/api-specification/next/api)
- [OpenDI JSON Schema](https://opendi.org/api-specification/next/schemas/cdm-full-schema)

## How to use

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) (or some other form of the Docker Engine).
2. Clone this repository. Ensure this project's [submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules) clone properly.
3. Ensure the `cdd-authoring-tool` submodule is using the `docker` branch. To switch branches, open a terminal in the `cdd-authoring-tool/` directory and run `git switch docker`.
4. From a terminal running in this repository's base directory, run `./full-rebuild-dev.sh` for a dev build or `./full-rebuild-prod.sh` for a production build.

## Services

This project defines 3 services:
- API
- Apache Frontend Server
- Nginx Reverse Proxy Server

It also defines one volume for the SQLite database, used by the API.

### API

The API is written in Go. It implements endpoints defined in the [OpenDI API Specification](https://opendi.org/api-specification/next/api) to maintain a basic database of CDM objects. This allows you to save and load different models in the frontend.

### Apache Frontend Server

The Apache server serves the frontend tool for authoring Causal Decision Diagrams. This service is exposed via the nginx reverse proxy at http://localhost. It uses the API for model persistence, and uses the [OpenDI JSON Schema](https://opendi.org/api-specification/next/schemas/cdm-full-schema) as its data format. The tool provides a graphical interface for creating CDDs from scratch, alongside a JSON data view for finer control and to demonstrate the structure of the JSON Schema.

### Nginx Reverse Proxy Server

This service is a basic reverse proxy, allowing the frontend server to access the API from within the Docker network, without exposing the API to the host machine (or to other outside connections, if services are being run in a distributed/production environment).