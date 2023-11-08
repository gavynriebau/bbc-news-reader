#!/bin/bash

# Grab the version number from the pubspec file.
VERSION=$(cat pubspec.yaml | grep '^version' | cut -d' ' -f2 | sed 's/\+/_/g')

flutter build apk --release
cp build/app/outputs/flutter-apk/app-release.apk simple-bbc-news-reader-v$VERSION.apk
gh release create simple-bbc-news-reader-v$VERSION.apk