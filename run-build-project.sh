# Recommend resetting your environment to clear out any dangling containers,
# images, or volumes before rebuilding.
# Use "run-reset-environment.sh" to do so.


# TO CONFIGURE YOUR BUILD:
# Make a copy of the SAMPLE.env file. Name this new file .env
# Set your config values in the new .env file accordingly.
# See comments in SAMPLE.env for details.


# Handle case where no config file is present:
# Offer to build with default values
if [ ! -f .env ]; then
    echo " "
    echo "--------------------------------------------"
    echo "WARNING: No .env configuration file present."
    echo "--------------------------------------------"
    echo " "
    echo "To configure the project, see SAMPLE.env"
    sleep 2

    # Read SAMPLE.env file to get defaults
    set -a
    . ./SAMPLE.env
    set +a
    echo " "
    echo "By default, the project will build using these values:"
    echo "BUILD_TYPE: $BUILD_TYPE"
    echo "DATABASE_TYPE: $DATABASE_TYPE"
    echo "DB_NAME: $DB_NAME"
    sleep 1s
    echo " "
    echo "Would you like to build using these default values? [y/N]: "
    read choice

    if [ "$choice" != "y" ]; then
        echo "Exiting..."
        sleep 1
        exit
    fi

    echo " "
    echo "-----------------------------------------"
    echo "Starting build with default configuration"
    echo "-----------------------------------------"
    echo " "
    sleep 1

    # Build with the defaults set in SAMPLE.env
    docker compose -f ./compose.yml --env-file ./SAMPLE.env up --build -d --force-recreate
    echo " "
    echo "----------------------------------------"
    echo "Script finished. Press enter to close..."
    echo "----------------------------------------"

    read _
    exit
fi
    
# Set environment variables for this shell's context
# These determine which build files to use
set -a
. ./.env
set +a

# Construct the build command based on environment variables
FILES_TO_COMPOSE="-f compose.yml"

if [ "$DATABASE_TYPE" = "mysql" ]; then
    FILES_TO_COMPOSE="$FILES_TO_COMPOSE -f compose.mysql.yml"
    if [ "$BUILD_TYPE" = "dev" ]; then
        FILES_TO_COMPOSE="$FILES_TO_COMPOSE -f compose.mysql.dev.yml"
    fi
fi

# Potential future database support would add new if statements here,
# similar to the ones directly above this comment.

if [ "$BUILD_TYPE" = "dev" ]; then
    FILES_TO_COMPOSE="$FILES_TO_COMPOSE -f compose.api.dev.yml"
fi

echo " "
echo "--------------------------------------------------"
echo "Starting build with files set to $FILES_TO_COMPOSE"
echo "--------------------------------------------------"
echo " "
sleep 1

docker compose $FILES_TO_COMPOSE up --build -d --force-recreate

echo " "
echo "----------------------------------------"
echo "Script finished. Press enter to close..."
echo "----------------------------------------"

read _
