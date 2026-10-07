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

1. Copy `api_keys.json.example` to `api_keys.json` for a shared development key,
   or copy it to `api_keys.android.json` and `api_keys.ios.json` for separate
   platform-restricted keys.
2. Set `GOOGLE_MAPS_API_KEY` in each selected file.
3. Run with `flutter run --dart-define-from-file=api_keys.json`, or pass the
   matching platform file when using separate keys.

Read the key in Dart via `AppSecrets.googleMapsApiKey` (`lib/core/config/app_secrets.dart`).
Android uses that define for its manifest placeholder, and iOS reads it from
Flutter's generated Xcode build settings at launch. Run Flutter with the define
file on both platforms; builds without it will have no Maps key. Keep
`api_keys.json` local. For platform-restricted production keys, Codemagic accepts
`GOOGLE_MAPS_ANDROID_API_KEY` and `GOOGLE_MAPS_IOS_API_KEY` as separate secrets;
the existing `GOOGLE_MAPS_API_KEY` remains a fallback during migration.

### Codemagic release setup

The `release` workflow imports the Codemagic variable group `HireHub Ja`. In
Codemagic, add these variables to that group and mark each one **Secret**:

| Variable | Value |
| --- | --- |
| `GOOGLE_MAPS_ANDROID_API_KEY` | Android Maps key from Google Cloud |
| `GOOGLE_MAPS_IOS_API_KEY` | iOS Maps key from Google Cloud |

Use the key value alone, without quotes or a `GOOGLE_MAPS_API_KEY=` prefix.
`GOOGLE_MAPS_API_KEY` is accepted as a temporary fallback for either platform.
Local `api_keys*.json` files are ignored by git and are not available in
Codemagic. The workflow checks both release keys before versioning and signing;
it reports missing variable names without printing key values.

Restrict each key in Google Cloud to its platform and the APIs it needs. For an
Android release distributed through Google Play, use the Play app signing
certificate fingerprint with the Android package name. The app currently calls
the Routes API directly from Flutter in `navigation_directions_service.dart`
using the compiled Maps key. A Codemagic secret does not hide that key in the
installed app. Move this request behind an authenticated backend endpoint
before relying on mobile app restrictions for routing. The backend is not part
of this repository.

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
