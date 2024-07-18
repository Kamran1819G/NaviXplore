# NaviXplore Project

## Overview

NaviXplore is a comprehensive mobile application designed to enhance the commuting experience in Navi Mumbai. It provides users with real-time information about metro and bus services, nearest stations, walking times, and other essential transportation details. Additionally, NaviXplore offers a platform for users to share posts about places, food, and moments of their life.

## Tech Stack

### Frontend

- **Flutter**: The application is built using Flutter, allowing for a seamless cross-platform experience on both Android and iOS devices.

### Backend

- **Firebase**: Initially used for authentication (email/password, Google, Apple) and real-time data storage.
- **Supabase**: An alternative backend option being explored for database management and user authentication.
- **GeoFlutterFire**: Utilized for geospatial queries to fetch nearby metro stations and bus stops.

### Database

- **Cloud Firestore**: Stores data related to metro stations, bus stops, and user posts.
- **Supabase Database**: Potentially replacing Firestore for enhanced database management.

### APIs

- **NMMTService API**: Used for fetching data related to NMMT buses.
- **Custom APIs**: For fetching NM Metro and express train information.

## Features

### Transportation

- **Nearest Metro Stations**: Displays nearby metro stations based on the user's location.
- **Walking Time Calculation**: Provides estimated walking time to metro stations.
- **Real-time Bus Information**: Fetches and displays real-time NMMT bus data, including nearby bus stops.
- **Express Train Information**: Displays express train schedules and relevant information.
- **Geospatial Queries**: Efficiently fetches nearest transportation options using geospatial queries.

### User Interaction

- **Authentication**: Secure sign-up and login options using email/password, Google, and Apple.
- **Posts Feature - XploreFeed**: Allows users to share posts about places, food, and moments, creating a community-driven platform for recommendations and experiences.

### Announcements

- **NMMT Bus Services Announcements**: Provides updates and announcements related to NMMT bus services to keep users informed about any changes or alerts.

## How to Use

1. **Download the App**: Install the NaviXplore application from the Google Play Store or Apple App Store.
2. **Sign Up/Log In**: Create an account or log in using email/password, Google, or Apple authentication.
3. **Explore Transportation Options**: Navigate through the app to find the nearest metro stations, bus stops, and express train schedules.
4. **Share Your Experiences**: Use the XploreFeed feature to share posts about places, food, or moments in your life.

