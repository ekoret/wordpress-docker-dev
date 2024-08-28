# Docker for WordPress

A general handbook for WordPress with Docker.

## General Usage

This simple handbook is my guide to working with WordPress and Docker easily. This is mainly used just to mock production sites to perform tests and new features locally.

# Table of Contents

- [Docker for WordPress](#docker-for-wordpress)
  - [General Usage](#general-usage)
- [Table of Contents](#table-of-contents)
  - [Docker Compose Configuration](#docker-compose-configuration)
  - [Development Docker Commands](#development-docker-commands)
      - [Check status of all containers.](#check-status-of-all-containers)
      - [Start the containers.](#start-the-containers)
      - [Stop the containers.](#stop-the-containers)
      - [Restart the containers.](#restart-the-containers)
      - [Stop and destroy containers.](#stop-and-destroy-containers)
      - [Stop, destroy, and remove volumes for containers](#stop-destroy-and-remove-volumes-for-containers)
      - [List volumes](#list-volumes)
      - [Remove a volume](#remove-a-volume)
      - [Remove all containers and volumes](#remove-all-containers-and-volumes)
      - [Export a SQL dump](#export-a-sql-dump)
      - [Import a SQL dump](#import-a-sql-dump)
      - [View PHP Error Logs](#view-php-error-logs)
      - [Find PHP \*.ini Files](#find-php-ini-files)
      - [error-logging.ini](#error-loggingini)
    - [Running WP-CLI](#running-wp-cli)
      - [Examples](#examples)
  - [Handling Permissions](#handling-permissions)
  - [To Do](#to-do)

## Docker Compose Configuration

Docker Compose Configuration

This compose.yaml file sets up a Docker environment tailored for WordPress development. It defines four services:

- `wordpress`: Runs the WordPress application. It is configured to restart on failure, exposes port 8080, and mounts local directories for WordPress files, themes, and plugins. It also includes a custom error-logging.ini for PHP error logging. It depends on the db service to be healthy before starting.

- `db`: Runs a MySQL database. It restarts on failure and uses environment variables to set up the database. It includes a health check to ensure it is running correctly.

- `wpcli`: Provides a WordPress CLI environment for managing WordPress from the command line. It uses the wordpress:cli image and mounts the WordPress directory. It is set to run with the user 33 (www-data) and depends on both the wordpress and db services.

- `phpmyadmin`: Offers a web interface for managing the MySQL database. It is accessible via port 8081 and connects to the db service.

The file also defines a volume named db to persist database data across container restarts.

- `wordpress` will be available at `localhost:8080`
- `phpmyadmin` will be available at `localhost:8081`
- `MySQL` port exposed on `8082`

## Development Docker Commands

#### Check status of all containers.

```bash
docker ps -a
```

#### Start the containers.

Start in detached mode to free up the terminal.

```bash
docker compose up -d
```

#### Stop the containers.

```bash
docker compose stop
```

#### Restart the containers.

```bash
docker compose restart
```

#### Stop and destroy containers.

```bash
docker compose down
```

#### Stop, destroy, and remove volumes for containers

This will not remove volumes that are bound to the host machine.

```bash
docker compose down -v
```

#### List volumes

```bash
docker volume ls
```

#### Remove a volume

```bash
docker volume rm [VOLUME_NAME]
```

#### Remove all containers and volumes

Stops all the containers, removes all the containers, then removes all volumes.

```bash
docker stop $(docker ps -q)
docker rm $(docker ps -a -q)
docker volume rm $(docker volume ls -q)
```

#### Export a SQL dump

Exports the contents of a MySQL database running in a Docker container to a SQL file on the host machine where the command was ran.

```bash
docker exec [CONTAINER_ID] mysqldump -u [USERNAME] -p[PASSWORD] [DATABASE_NAME] > backup.sql
```

#### Import a SQL dump

Imports a SQL backup file from the current directory into a MySQL database running in a Docker container.

```bash
docker exec -i [CONTAINER_ID] mysql -u [USERNAME] -p[PASSWORD] [DATABASE_NAME] < backup.sql
```

#### View PHP Error Logs

Watches the PHP error log file for the specified container. This is useful if for some reason the container cannot write the logs to the bind mount.

```bash
docker logs -f --details [CONTAINER_NAME]
```

#### Find PHP \*.ini Files

This will help identify where the `php.ini` files are located in the container.

```bash
docker exec -it [CONTAINER_NAME] php --ini
```

#### error-logging.ini

This file will set custom error logging settings to ensure that the PHP errors are output into the bind mount `wordpress/wp-content/debug.log`. It uses the default settings other than the error_log key being set to `/var/www/html/wp-content/debug.log`. This was done because there are issues with using `error_log` within the theme and the `debug.log` file was not being generated.

You can also set it manually within the container with the following commands:

```bash
docker exec -it [CONTAINER_NAME] bash
nano /usr/local/etc/php/conf.d/error-logging.ini
```

### Running WP-CLI

WP-CLI runs in it's own container. It needs to have the WordPress installation available to it.

Running a wpcli command with compose.
`docker compose run --rm [SERVICE_NAME] [COMMAND]`

#### Examples

```bash
# Skip the WordPress installation
docker compose run --rm wpcli core install --url="http://localhost:8080" --title="My WordPress Site" --admin_user="admin" --admin_password="password" --admin_email="admin@example.com" --skip-email

# Get an option
docker compose run --rm wpcli option get blogname

# Update an option
docker compose run --rm wpcli option update siteurl "http://localhost:8080"

# Check WordPress core version
docker compose run --rm wpcli core version
```

## Handling Permissions

If you are receiving file permission errors when attempting to save a file in VS Code, follow these steps:

Check if the current user is in the `www-data` group.

```bash
groups
```

or

```bash
id
```

If the user is not in the group, add it to the `www-data` group.

```bash
sudo usermod -aG www-data $(whoami)
```

Ensure mounted volumes have correct permissions so you can edit files locally.

```bash
find wordpress -type f ! -path "./.git/" -exec chmod 664 {} \;
find plugins -type f ! -path "./.git/" -exec chmod 664 {} \;
find themes -type f ! -path "./.git/" -exec chmod 664 {} \;
find wordpress -type d ! -path "./.git/" -exec chmod 755 {} \;
find plugins -type d ! -path "./.git/" -exec chmod 755 {} \;
find themes -type d ! -path "./.git/" -exec chmod 755 {} \;
```

It is recommended to have 644 permissions for files and 755 permissions for a WordPress installation in production.

```bash
find . -type f -exec chmod 644 {} \;
find . -type d -exec chmod 755 {} \;
```

If there is a .git folder inside of the plugin directory, ignore it.

```bash
find . -type f ! -path "./.git/" -exec chmod 644 {} \;
find . -type d ! -path "./.git/" -exec chmod 755 {} \;
```

When working with Docker, you will need to set the ownership of files as 664 to enable you to edit from the bind mount.

```bash
find . -type f -exec chmod 664 {} \;
```

## To Do

- Create CRON job to create SQL dumps
- Create script to create a SQL dump when the container stops/shuts down
- Run install command when wpcli container starts to skip installation process
- Ensure plugins can write to wp-content/uploads. ex. woocommerce logs
- Create a separate database container to handle tests in Docker instead of local
- Format commands in README better
