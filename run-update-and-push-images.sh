# Config: Docker Hub repos
API_REPO="iamkeldev/opendi-example-api-go"
CDD_TOOL_REPO="iamkeldev/opendi-cdd-authoring-tool"

# Load current versions from the current SAMPLE.env
set -a
. ./SAMPLE.env
set +a

echo " "
echo "This script is for pushing new tagged Images when the API or CDD Tool submodules are updated."
echo " "
sleep 1

# Prompt for new version numbers
echo "Current API version in SAMPLE.env: ${API_IMAGE_VERSION}"
echo "Enter a new version tag for the API (LEAVE BLANK TO SKIP):"
read newAPIVersion

echo " "
echo "Current CDD Tool version in SAMPLE.env: ${CDD_TOOL_IMAGE_VERSION}"
echo "Enter a new version tag for the CDD Tool (LEAVE BLANK TO SKIP):"
read newCDDToolVersion
echo " "

# Make sure at least one new version was requested
if [ -z "$newAPIVersion" ] && [ -z "$newCDDToolVersion" ]; then
    echo "No new version tags requested. Exiting..."
    echo " "
    echo "----------------------------------------"
    echo "Script finished. Press enter to close..."
    echo "----------------------------------------"

    read _
    exit 1
fi

# Confirm new version(s)
echo "The following images will be built and pushed:"
[ -n "$newAPIVersion" ] && echo "- $API_REPO:$newAPIVersion and $API_REPO:latest"
[ -n "$newCDDToolVersion" ] && echo "- $CDD_TOOL_REPO:$newCDDToolVersion and $CDD_TOOL_REPO:latest"
echo " "
echo "Continue? [y/N]"
read confirmBuildAndPush
echo " "

if [ "$confirmBuildAndPush" != "y" ]; then
    echo "Exiting..."
    sleep 1
    exit
fi

# Build and push new API version (if requested)
if [ -n "$newAPIVersion" ]; then
    echo " "
    echo " "
    echo "Building and tagging API images..."
    docker build -t $API_REPO:$newAPIVersion -t $API_REPO:latest ./go-model-api
    echo " "
    echo " "
    echo "Pushing new API images to Docker Hub"
    docker push $API_REPO:$newAPIVersion
    docker push $API_REPO:latest
    echo " "
fi

if [ -n "$newCDDToolVersion" ]; then
    echo " "
    echo " "
    echo "Building and tagging CDD Tool images..."
    docker build -t $CDD_TOOL_REPO:$newCDDToolVersion -t $CDD_TOOL_REPO:latest ./cdd-authoring-tool
    echo " "
    echo " "
    echo "Pushing new CDD Tool images to Docker Hub"
    docker push $CDD_TOOL_REPO:$newCDDToolVersion
    docker push $CDD_TOOL_REPO:latest
    echo " "
fi

# Suggest some manual updates
echo " "
echo "Finished building and pushing requested images."
echo " "
echo "---------"
echo "REMINDERS"
echo "---------"
echo " "

if [ -n "$newAPIVersion" ]; then
    echo "Consider updating SAMPLE.env with new API version, if it is considered STABLE:"
    echo "API_IMAGE_VERSION=$newAPIVersion"
    echo " "
fi

if [ -n "$newCDDToolVersion" ]; then
    echo "Consider updating SAMPLE.env with new CDD Tool version, if it is considered STABLE:"
    echo "CDD_TOOL_IMAGE_VERSION=$newCDDToolVersion"
    echo " "
fi

echo " "
echo "----------------------------------------"
echo "Script finished. Press enter to close..."
echo "----------------------------------------"

read _
exit