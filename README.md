# ChatterBox

ChatterBox is a simple real-time chat app for finding people and having one-to-one conversations. It uses Google Sign-In for authentication and Socket.IO to deliver messages live.

## Tech stack

- Flutter and Dart (Android client)
- Node.js and Express (API)
- MongoDB (user data)
- Socket.IO (real-time messaging)
- Riverpod (client state management)

## Configuration

Create a root `.env` for the Flutter app and a `server/.env` for the API. Set the API host, Google OAuth client IDs, MongoDB connection string, server port, and JWT secret in the appropriate file. These files contain local configuration and are excluded from Git.
