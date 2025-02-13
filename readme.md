# Containerized CDD Authoring Demo

This project defines a Docker Container setup that will create a set of services which can be run locally or distributed, to enhance the [OpenDI CDD Authoring Tool](https://opendi.org/cdd-authoring-tool/) with basic data persistence.  
This allows users to perform basic [CRUD](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete) operations on models they create with this tool. When run locally, these models are saved locally in a SQLite database file within the defined Docker volume.

The services in this project interoperate via compliance with these OpenDI Interoperability Standards:
- [OpenDI API Specification](https://opendi.org/api-specification/next/api)
- [OpenDI JSON Schema](https://opendi.org/api-specification/next/schemas/cdm-full-schema)

## How to use

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) (or some other form of the Docker Engine).
2. Clone this repository. Ensure this project's [submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules) clone properly.
3. (Optional) If you wish to use a different version of the `cdd-authoring-tool` submodule, start a terminal in the top-level directory of that project and run `git switch [branch]` to switch to the desired feature or version branch.
4. (Optional) To configure your build to use to production or development (exposes ports to localhost) versions, or to configure your database backend (currently for SQLite or MySql), edit the `.env` file in the repository's base directory. 
5. From a terminal running in this repository's base directory, run `./run-build-project.sh` to build the project.

To clear all Docker images, volumes, and containers created from the above process, run `./run-reset-environment.sh` from this repository's base directory.  
NOTE: Deleting volumes will DELETE ALL DATA from any databases you have created for this project.

To clear disk space used by Docker, you may also occasionally wish to clear your build cache. Run `docker system df` for a report on build cache size, and `docker builder prune` to clear build cache.

## Configuring the project

This project has one primary configuration file, `.env`. The Authoring Tool Frontend submodule has an additional `docker-config.js`, and the nginx service has configs used under different build conditions determined by `.env` values.

### `.env`

Location: Top level parent directory for the Containerized Authoring Demo project.

Provides configuration options for build type, database type, and database configurations.

#### Config Descriptions

`BUILD_TYPE`: Determines whether to use Compose files that were configured for a production build, or a development build.  
- *Option "dev"*: Adds compose.api.dev.yml and compose.mysql.dev.yml (when relevant) to the main compose build command. This exposes to the localhost network port 8080 for the API, and port 3306 for the MySQL server (if used).
- *Option "prod"*: Leaves all dev variants of compose files out of the main compose build command, leaving only the nginx ports 80 and 443 exposed for accessing the frontend. This secures the API and database behind the nginx reverse proxy.

`DATABASE_TYPE`: Determines which database system the API will use.  
- *Option "sqlite"*: API will use a SQLite database, stored as a file called $DB_NAME.db in the database volume "db-data".
- *Option "mysql"*: API will use a MySQL database server, running on service "db", using database configuration values given below.

`DB_HOST`: *MySQL only.* The host base URL for the database. Used by the API to access the database.  
Defaults to "db", as this URL will be resolved by the nginx server to address the database so long as it remains within the Docker Compose project's network.  
This value is "127.0.0.1" in the "dsn" value in [this GORM example](https://gorm.io/docs/connecting_to_the_database.html#MySQL).

`DB_PORT`: *MySQL only.* The port used at the host's base URL for accessing the database.  
Defaults to "3306", as this is the default port used by MySQL.  
This value is "3306" in the "dsn" value in [this GORM example](https://gorm.io/docs/connecting_to_the_database.html#MySQL).

`DB_USER`: *MySQL only.* The main username used to configure the MySQL server.  
Arbitrarily defaults to "myuser".  
This value is "user" in the "dsn" value in [this GORM example](https://gorm.io/docs/connecting_to_the_database.html#MySQL).

`DB_PASSWORD`: *MySQL only.* Password associated with the username given in DB_USER. Used to configure the MySQL server.  
Arbitrarily defaults to "defaultpassword".
This value is "pass" in the "dsn" value in [this GORM example](https://gorm.io/docs/connecting_to_the_database.html#MySQL).

`DB_NAME`: The name of the database.  
*For SQLite*, the full filename is created by appending ".db" to this value.  
*For MySQL*, this value is given directly during configuration.  
Arbitrarily defaults to "modelsdb". This becomes "modelsdb.db" for the SQLite file.
For SQLite, this value is the "gorm" portion of the value passed to sqlite.Open() in [this GORM example](https://gorm.io/docs/connecting_to_the_database.html#SQLite).  
For MySQL, this value is "dbname" in the "dsn" value in [this GORM example](https://gorm.io/docs/connecting_to_the_database.html#MySQL).

### `docker-config.js`

Location: `cdd-authoring-tool/docker-config.js`.

Provides configuration options for the CDD Authoring Tool frontend.

Most relevant to this project is the `apiBaseURI` option, which is set to `/api` by default. This is the value used by services within the private network created by Docker Compose. If you intend to host an OpenDI-compliant API separately, change this to your API's base URI.

### NGINX Configs

Location: `nginx-configs/`.

Provides specification(s) for the nginx server.

`nginx-sqlite.conf`: used if `DATABASE_TYPE` is set to "sqlite" in `.env`. Defines an `/api/` and `/` locations for internal network members to address. These are for the API and Authoring Frontend, respectively.

`nginx-db.conf`: used if `DATABASE_TYPE` is set to "mysql" in `.env`. Adds a `/db/` location for internal network members to address.

## Services

This project defines 3-4 services:
- API
- Apache Frontend Server
- Nginx Reverse Proxy Server
- MySQL server (if configured for MySQL)
- SQLite volume (if configured for SQLite)

### API

The API is written in Go. It implements endpoints defined in the [OpenDI API Specification](https://opendi.org/api-specification/next/api) to maintain a basic database of CDM objects. This allows you to save and load different models in the frontend.

For services running within the Docker Compose project's private network, the API can be accessed at the address `/api:8080`. When the project is built in `dev` mode, the API is also exposed to `localhost:8080`.

### Apache Frontend Server

The Apache server serves the frontend tool for authoring Causal Decision Diagrams. This service is exposed via the nginx reverse proxy at http://localhost. It uses the API for model persistence, and uses the [OpenDI JSON Schema](https://opendi.org/api-specification/next/schemas/cdm-full-schema) as its data format. The tool provides a graphical interface for creating CDDs from scratch, alongside a JSON data view for finer control and to demonstrate the structure of the JSON Schema.

### Nginx Reverse Proxy Server

This service is a basic reverse proxy, allowing the frontend server to access the API from within the Docker network, without exposing the API to the host machine (or to other outside connections, if services are being run in a distributed/production environment).

### Database

#### MySQL

This service is a basic MySQL server, configured using the host URL/port, username/password, and database name values set in `.env`.

For services running within the Docker Compose project's private network, the database can be accessed at the address `/db:3306`. When the project is built in `dev` mode, the MySQL database is also exposed to `localhost:3306`.

#### SQLite

When using a SQLite database, no `db` service is created. Instead, SQLite only needs space for its database file, so the `db-data` volume is all that is needed. This volume is mounted in the API service, which creates and accesses the database there, using the `DB_NAME` value from `.env` for the filename (with the `.db` file ending added).

## Adding support for more databases

**Want to use PostgreSQL, or another database tool?** That should be doable.  
This section provides a rough outline of the changes required to add support for another database type.

### Verify GORM support

This project uses [GORM](https://gorm.io/) for object-relational mapping.

GORM supports the databases listed here: [Connecting to a Database](https://gorm.io/docs/connecting_to_the_database.html).

### Adjust environment variables

Database configuration uses environment variables to pass information through the initial build process and down to the Go API. You'll want to edit `.env`, listing a new possible value for `DATABASE_TYPE`, and adding any additional configuration variables (if any) needed to initialize your database. 

See the `environment:` key in `compose.mysql.yml` for an example of how these values are converted into environment variables within the Go API environment.

### Add compose file(s)

Your new database will need its own service defition, provided in additonal Docker Compose YAML files. For an example of what these should look like, see `compose.mysql.yml` and `compose.mysql.dev.yml`.

To integrate these new compose files, see the comment in `run-build-project.sh` about "potential future database support".

Ensure any new compose files are also added to the list in `run-reset-environment.sh`.

### Make an nginx config file (if necessary)

Read `nginx-db.conf` to determine whether this file will work for your new database. If not, make a new one. See next section.

#### Modify main `compose.yml` (if necessary)

If you made a new nginx config file, add it as a new condition in the terminal command defined in the `command:` key under the `nginx` service in `compose.yml`.

If you DID NOT make a new nginx config file and your new database will use the `nginx-db.conf` file, your case should be covered by the default condition in the terminal command defined int he `command:` key under the `nginx` service in `compose.yml`. In this case, you won't need to make changes.

### Add code to the Go API

In `go-model-api/db/dbFactory.go`:  
- Add the relevant GORM driver to the imports.
- Adjust DBConfig with any new environment variables, if needed.
- Adjust `GetConfig` with logic for retrieving these values from the environment.
- In `GetDatabase`, add a new `case` for the new `DATABASE_TYPE` value you want to support.
- Inside your new `case`, put the code for initializing/opening your databse. See [the GORM docs for Connecting to a Database](https://gorm.io/docs/connecting_to_the_database.html) for example code for all supported databases.

### Test your new implementation

Some acceptable SQL syntax differs between database implementations. Make sure you test all endpoints. For a quick test, Docker Desktop allows you to view console output for running containers. Build the project, then test it in your browser, and check Logs on Docker Desktop for full internal error messages.

### Submit a Pull Request!

If you go through all of the above steps, please submit a PR so that we can incorporate your database support work in the public version of this project! We'd love to eventually support more GORM-friendly databases.