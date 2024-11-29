FROM ubuntu:latest
LABEL authors="SyvertJayMartorinio"

ENTRYPOINT ["top", "-b"]

FROM cirrusci/flutter:stable AS flutter_builder

WORKDIR /app

COPY . .

RUN flutter pub get

RUN flutter build apk --release  # or flutter build web

FROM node:16 AS node_builder

WORKDIR /api

COPY api/package*.json ./

RUN npm install

COPY api/ .

# Expose the port your API runs on (e.g., 3000 for a typical Node.js app)
EXPOSE 3000

# Start your Node.js app (adjust the command based on your app entry point)
CMD ["npm", "start"]

# Stage 3: Final Image (optional)
FROM node:16

# Copy Flutter build artifacts (if you want to serve the app directly from Docker)
COPY --from=flutter_builder /app/build/app/outputs/flutter-apk/app-release.apk /app-release.apk

# Copy Node.js app files from the previous stage
COPY --from=node_builder /api /api

# Expose necessary ports
EXPOSE 3000

# Set the entry point for both API and Flutter (if you need to run both in the same container)
CMD ["npm", "start"]
