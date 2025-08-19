#!/bin/bash
# make_full_project.sh
# Usage: run this on your machine (Linux/macOS) where Flutter is installed.
# It will create a new Flutter project and copy the provided lib/, pubspec.yaml and other files into it.
# After running, run `flutter pub get` inside the created project and then `flutter run`.

set -e

PROJ_NAME="ai_mood_companion_full"
echo "Creating Flutter project '$PROJ_NAME' (requires flutter SDK installed)..."

if ! command -v flutter &> /dev/null
then
    echo "Error: flutter CLI not found in PATH. Install Flutter SDK and ensure 'flutter' is available."
    exit 1
fi

# Create temp project
flutter create --org com.example --project-name $PROJ_NAME $PROJ_NAME

echo "Copying files into $PROJ_NAME..."
# Copy over files from current directory (the zip contents) into the new project
# Assumes this script is run from the directory where you've unzipped the ai_mood_companion.zip contents.
cp -r lib "$PROJ_NAME"/
cp pubspec.yaml "$PROJ_NAME"/
cp codemagic.yaml "$PROJ_NAME"/ || true
cp .env.example "$PROJ_NAME"/.env.example || true
cp -r android/* "$PROJ_NAME"/android/ 2>/dev/null || true

echo "Files copied. Now run:"
echo "  cd $PROJ_NAME"
echo "  flutter pub get"
echo "  flutter run"
echo ""
echo "If you face Android Gradle or SDK issues, ensure Android Studio and SDK are installed and ANDROID_HOME/ANDROID_SDK_ROOT are set."
