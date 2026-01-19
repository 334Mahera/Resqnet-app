# resqnet_app

A new Flutter project.

🚨 ResQNet – Emergency Response & Volunteer Coordination App

ResQNet is a real-time emergency assistance mobile application built with Flutter and Firebase, designed to connect people in distress with nearby volunteers and administrators for faster response during emergencies.

The app supports live location tracking, role-based access, and real-time status updates, inspired by real-world on-demand platforms.

## Key Features
👤 User (Help Seeker)

SOS emergency request creation

Category-based emergency requests (Fire, Medical, Accident, Flood)

Live volunteer tracking on map (Blinkit-style experience)

Real-time status updates (Assigned → On the way → Arrived)

Location sharing with volunteers

🚑 Volunteer

Accept nearby emergency requests

Live GPS tracking while responding

Route visualization using Google Maps

Status flow management (Start → Arrived → Complete)

Online / Offline availability toggle

🛡 Admin

Centralized dashboard to monitor all requests

View user & volunteer details

Force complete or cancel requests

Reassign volunteers if required

Analytics dashboard with charts & insights

## Tech Stack

Frontend: Flutter (Material UI)

Backend: Firebase (Authentication, Firestore, Hosting)

Maps & Location: Google Maps API, Geolocator

State Management: Provider

Real-time Updates: Firestore Streams

Architecture: Modular + Service-based architecture

## Core Highlights

Real-time location streaming (volunteer GPS)

Role-based routing (User / Volunteer / Admin)

Secure environment variable handling (API keys excluded)

Clean UI inspired by production apps (Blinkit-style UX)

Scalable Firebase data model

## Security Note
API keys, Firebase credentials, and secrets are not committed to this repository.

## 📸 App Screenshots

###  User Flow
![User Home](https://raw.githubusercontent.com/334Mahera/Resqnet-app/main/user_home.png)

![Live Tracking](https://raw.githubusercontent.com/334Mahera/Resqnet-app/main/live tracking.png)

###  Volunteer Flow
![Volunteer Home](https://raw.githubusercontent.com/334Mahera/Resqnet-app/main/volunteer_home.png)
![Volunteer Requests](https://raw.githubusercontent.com/334Mahera/Resqnet-app/main/volunteer_requests.png)
![Live Map](https://raw.githubusercontent.com/334Mahera/Resqnet-app/main/live_map.png)

###  Admin Panel
![Admin Dashboard](https://raw.githubusercontent.com/334Mahera/Resqnet-app/main/admin_dashboard.png)
![Admin Analytics](https://raw.githubusercontent.com/334Mahera/Resqnet-app/main/admin_analytics.png)

