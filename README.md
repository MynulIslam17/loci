# Loci – Social Media Platform for Businesses

![Project Banner](assets/images/project_banner.png)

## Overview

Loci is a dynamic social media ecosystem designed specifically for businesses to connect with their community. It allows business owners to create profiles, promote exclusive events, generate engaging raffles, and handle real-time networking—all within a seamless mobile experience.

## Key Features

- Business Profiles: Dedicated spaces for businesses to showcase their brand, location, and services.
- Event Management: Create, promote, and manage exclusive community events.
- Interactive Raffles: Generate engagement through digital raffles and promotional activities.
- Real-time Communication: Instant messaging between businesses and users powered by WebSockets.
- Live Map Integration: Discover local businesses and events through an interactive map interface.
- Networking Dashboard: Overview of contacts, referrals, and upcoming meetings.
- Secure Authentication: Robust user and business verification using JWT.

## Local secrets (Maps API key)

Compile-time keys stay out of git. After cloning:

1. `cp api_keys.json.example api_keys.json`
2. Set `GOOGLE_MAPS_API_KEY` in `api_keys.json`
3. Run with: `flutter run --dart-define-from-file=api_keys.json`

Read the key in Dart via `AppSecrets.googleMapsApiKey` (`lib/core/config/app_secrets.dart`).
Android uses that define for its manifest placeholder, and iOS reads it from
Flutter's generated Xcode build settings at launch. Run Flutter with the define
file on both platforms; builds without it will have no Maps key. Keep
`api_keys.json` local. For platform-restricted production keys, Codemagic accepts
`GOOGLE_MAPS_ANDROID_API_KEY` and `GOOGLE_MAPS_IOS_API_KEY` as separate secrets;
the existing `GOOGLE_MAPS_API_KEY` remains a fallback during migration.
The app also calls Routes and Directions web services directly from Flutter;
move those calls behind the backend before applying mobile-app restrictions to
their key. Google recommends separate keys for Android and iOS app restrictions.

## Technology Stack

### Frontend
- Dart
- Flutter
- GetX (State Management)
- GetStorage (Local Storage)

### Backend
- Node.js
- Express.js
- MongoDB
- Socket.io
- JSON Web Tokens (JWT)
