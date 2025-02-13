# Recommend resetting your environment to clear out any dangling containers,
# images, or volumes before rebuilding.
# Use "run-reset-environment.sh" to do so.


# TO CONFIGURE YOUR BUILD:
# Edit the file called .env

if [ -f .env ]; then
    set -a
    source .env
    set +a
fi

#In case variables were not set correctly, apply defaults
: "${DATABASE_TYPE:=}"
: "${DB_HOST:=}"
: "${DB_PORT:=}"
: "${DB_USER:=}"
: "${DB_PASSWORD:=}"
: "${DB_NAME:=modelsdb}"

# Construct the build command based on environment variables
FILES_TO_COMPOSE="-f compose.yml"

if [ "$DATABASE_TYPE" == "mysql" ]; then
    FILES_TO_COMPOSE="$FILES_TO_COMPOSE -f compose.mysql.yml"
    if [ "$BUILD_TYPE" == "dev" ]; then
        FILES_TO_COMPOSE="$FILES_TO_COMPOSE -f compose.mysql.dev.yml"
    fi
fi

# Potential future database support would add new if statements here,
# similar to the ones directly above this comment.

if [ "$BUILD_TYPE" == "dev" ]; then
    FILES_TO_COMPOSE="$FILES_TO_COMPOSE -f compose.api.dev.yml"
fi

echo " "
echo "--------------------------------------------------"
echo "Starting build with files set to $FILES_TO_COMPOSE"
echo "--------------------------------------------------"
echo " "
sleep 1.5s

docker compose $FILES_TO_COMPOSE up --build -d --force-recreate

echo " "
echo "------------------------------------------"
echo "Script finished. Press any key to close..."
echo "------------------------------------------"

read -n 1