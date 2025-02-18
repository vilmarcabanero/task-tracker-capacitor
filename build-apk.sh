#!/bin/bash

# Exit immediately if any command fails
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No color

# Function to display error message and exit
handle_error() {
    echo -e "${RED}❌ Error occurred! Exiting...${NC}"
    exit 1
}

# Trap errors and run handle_error function
trap 'handle_error' ERR

clean_build() {
    echo -e "\n${GREEN}🧹 Cleaning previous Gradle builds...${NC}"
    cd android
    ./gradlew clean
    cd ..
}

# Run clean_build if "--clean" flag is provided
if [[ "$1" == "--clean" ]]; then
    clean_build
fi

echo -e "\n${GREEN}🚀 Building React app...${NC}"
npm run build

echo -e "\n${GREEN}🔄 Syncing project with Android...${NC}"
npx cap sync android

# Navigate to Android directory
cd android

echo -e "\n${GREEN}📦 Building signed release APK...${NC}"
./gradlew assembleRelease

# Go back to project root
cd ..

# Find APK file
APK_DIRECTORY=android/app/build/outputs/apk/release/
APK_PATH=$(find $APK_DIRECTORY -name "*.apk" | head -n 1)

if [[ -f "$APK_PATH" ]]; then
    echo -e "\n${GREEN}✅ Signed release APK built successfully!${NC}"
    echo -e "📍 APK location: ${APK_PATH}"
    open $APK_DIRECTORY
else
    echo -e "\n${RED}❌ APK build failed. No APK found.${NC}"
    exit 1
fi

: '
# Optional: Install APK to a connected device
read -p "Do you want to install the APK on a connected device? (y/n): " install_apk

if [[ "$install_apk" == "y" ]]; then
    echo -e "\n${GREEN}📲 Installing APK on device...${NC}"
    adb install -r "$APK_PATH" && echo -e "\n${GREEN}✅ APK installed successfully!${NC}" || echo -e "\n${RED}❌ Failed to install APK.${NC}"
fi

echo -e "\n${GREEN}🎉 Done!${NC}"
'

# TODO: Screate a script that will call a POST /upload-apk endpoint, which will upload the APK to the server, and should reflect in the mobile app.
# The app will create a screen dedicated to the list of app versions (with APK link).
