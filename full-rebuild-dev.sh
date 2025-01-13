# This will remove all containers, volumes, and images
# created from the last run of docker compose up,
# AND containers for services not defined in the Compose file.

docker compose down -v --remove-orphans --rmi all

# Build and run services
docker compose -f compose.dev.yml -f compose.yml up --build -d --force-recreate