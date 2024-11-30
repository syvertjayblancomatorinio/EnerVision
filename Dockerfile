# Stage 1: Base Image for Flutter Build
FROM cirrusci/flutter:stable AS flutter_builder
WORKDIR /back_end

# Update Flutter SDK to get the latest Dart version
RUN flutter upgrade

# Copy the Flutter app and install dependencies
COPY . .
RUN flutter pub get

# Build the Flutter APK (or Web)
RUN flutter build apk --release  # Change to `flutter build web` for a web app

# Stage 2: Base Image for Node.js API
FROM node:16 AS node_builder
WORKDIR /back_end

# Copy Node.js app dependencies and install them (adjusted to the back_end directory)
COPY back_end/package*.json ./
RUN npm install

# Copy the rest of the back_end files
COPY back_end/ .

# Expose the API port
EXPOSE 3000

# Start the Node.js app
CMD ["npm", "start"]

# Stage 3: Final Image (optional)
FROM ubuntu:latest
LABEL authors="SyvertJayMartorinio"

# Expose the port your API runs on
EXPOSE 3000

# Copy Flutter build artifacts (for APK or Web)
COPY --from=flutter_builder /app/build/app/outputs/flutter-apk/app-release.apk /app-release.apk

# Copy the Node.js backend files from the previous stage (adjusted to back_end directory)
COPY --from=node_builder /back_end /back_end

# Start the Node.js API (or another approach if you need both the API and Flutter app)
CMD ["npm", "start"]
