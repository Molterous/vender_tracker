# 📱 Vender Tracker

A robust Android application for real-time workforce management, including task assignment, attendance tracking, live location monitoring, and quotation handling.

---

## 🚀 Features Overview

### 🔐 Authentication & Role Management
- Secure login with role-based access.
- Two distinct user roles:
    - **Admin**: Full access to user, task, and data management.
    - **User**: Limited access based on assignments and profile.
- Admin can create, edit, or delete users.

### 👤 User Profile Management
- Users can view and update their:
    - Name
    - Profile photo
    - Contact information
    - Designation & address

### 📍 Live Location Tracking
- 24/7 user location tracking (lat, long, timestamp).
- Admin dashboard map for real-time user tracking and history.

### 📋 Task Management System
#### Admin
- Assign tasks with title, description, and due date.
- Monitor task status: `Assigned → In Progress → Completed`.

#### User
- Receive task notifications.
- Accept, start, and complete tasks from the dashboard.

### 📑 Quotation Module
- Users can fill out dynamic quotation forms.
- Admin can configure fields, review submissions, and export data.

### 🕒 Attendance Management
- Users can mark login/logout.
- Tracks working hours and monthly presence.
- Attendance summaries viewable in dashboards.

### 📊 Dashboards
#### Admin
- Summary of:
    - Total and active users
    - Task distribution by status
    - Attendance data
    - Location map overview

#### User
- Profile snapshot
- Attendance calendar
- Task summary and statuses

### 🔔 Notifications
- Real-time push notifications for:
    - New task assignments
    - Reminders
    - Login/Logout confirmations

---

## 📷 Screenshots
> _Add screenshots or screen recordings of the app in action here._

---

## 🛠️ Tech Stack

- **Frontend**: Jetpack Compose (Android)
- **Backend**: Kotlin-based services integrated with Appwrite
- **Database**: Appwrite (Cloud), previously Room (Local)
- **Maps**: Google Maps API
- **Push Notifications**: Firebase Cloud Messaging (FCM)

---

## 🧪 How to Build

1. Clone the repo:
   ```bash
   git clone https://github.com/Molterous/vender_tracker.git
````

2. Open in **Android Studio**.

3. Add the required **Google Maps API key** and **Firebase configuration** files.

4. Run the app on an emulator or physical device with location permission enabled.

---

## 🔐 Permissions Required

* Location (foreground & background)
* Internet
* Notification access
* Storage (optional for image uploads)

---

## 📦 Project Modules

* `authentication/` – Login and role-based session management
* `location/` – Background live tracking with AlarmManager & foreground service
* `tasks/` – Task CRUD operations & syncing with Appwrite
* `attendance/` – Time tracking and day-wise logs
* `quotations/` – Dynamic quotation form module
* `ui/` – All Jetpack Compose UI screens
* `viewmodels/` – State management and business logic layer

---

## 🤝 Contributors

* **[@Molterous](https://github.com/Molterous)** – Lead Developer

---

## 📄
