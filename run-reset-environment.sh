# This will remove all containers, volumes, and images
# created from any of this project's compose files
echo "This command will remove all containers, volumes, and images from ALL previous builds associated with this project."
echo "This includes ALL data stored in your models database."
sleep 1
echo " "
echo "Are you sure? [y/N]: "
read choice

if [ "$choice" = "y" ]; then
    echo "Removing all containers, volumes, and images from previous builds."
    echo " "
    docker compose -f compose.yml -f compose.api.dev.yml -f compose.mysql.yml -f compose.mysql.dev.yml down -v --rmi all
    echo " "
    echo "----------------------------------------"
    echo "Script finished. Press enter to close..."
    echo "----------------------------------------"

    read _
else
    echo "Exiting..."
    sleep 1
fi
