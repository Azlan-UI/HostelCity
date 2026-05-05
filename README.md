# Hostel Management System (HMS) - Cinematic PropTech Experience

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Riverpod](https://img.shields.io/badge/Riverpod-764ABC?style=for-the-badge&logo=riverpod&logoColor=white)](https://riverpod.dev)

A premium, high-performance **Hostel Management System** built with Flutter and Firebase. This application provides a seamless "PropTech" experience with a cinematic interface, glassmorphic design elements, and a robust multi-role architecture tailored for Students, Hostel Admins, and Platform Administrators.

---

## 🌟 Key Features

### 🎓 Student Experience
- **Cinematic Discovery**: Browse hostels with a premium UI, interactive filters (Price, Gender, Location), and smooth animations.
- **Interactive Map**: Discover hostels nearby using an OpenStreetMap-powered interface.
- **Hassle-free Booking**: Streamlined booking process with real-time availability.
- **Active Stay Dashboard**: Manage your current residence, track dues, and raise complaints through a dedicated portal.
- **Smart Complaints**: Submit and track maintenance or service issues with photo attachments and status updates.

### 🏢 Hostel Admin Portal
- **Resident Management**: Overview of all residents, room assignments, and check-in/out status.
- **Financial Tracking**: Monitor payments, manage dues, and generate billing reports.
- **Complaint Resolution**: Efficient workflow to receive, assign, and resolve student issues.
- **Booking Control**: Approve or reject new booking requests with automated notifications.

### 👑 Platform Administration
- **Global Overview**: High-level statistics on platform growth, revenue, and user engagement.
- **Hostel Verification**: Audit and approve new hostel listings to maintain quality standards.
- **System Configuration**: Manage global settings and user permissions.

### 🎨 Design & UX
- **Cinematic UI/UX**: Deep Noir and Light modes with glassmorphic components for a premium feel.
- **Micro-interactions**: Smooth transitions and micro-animations powered by `Animate Do` and `Lottie`.
- **Responsive Layouts**: Optimized for various mobile screen sizes.

---

## 🛠 Tech Stack

- **Frontend**: [Flutter](https://flutter.dev) (Dart)
- **State Management**: [Riverpod](https://riverpod.dev) (Reactive & Robust)
- **Backend**: [Firebase](https://firebase.google.com)
    - **Authentication**: Multi-role login (Email/Password).
    - **Cloud Firestore**: Real-time NoSQL database.
    - **Cloud Storage**: Secure media hosting for profiles and complaints.
    - **Cloud Messaging**: Push notifications for booking updates and dues.
- **Maps**: [Flutter Map](https://pub.dev/packages/flutter_map) (OpenStreetMap)
- **Animations**: `Animate Do`, `Shimmer`, `Lottie`.
- **Image Hosting**: [Cloudinary](https://cloudinary.com) for high-performance asset delivery.

---

## 📂 Project Structure

The project follows a **Clean Architecture** pattern to ensure scalability and maintainability:

```text
lib/
├── core/           # Design system, themes, constants, and global utilities
├── data/           # Models, DTOs, and Repository implementations
├── domain/         # Business logic entities and Repository interfaces
├── presentation/   # UI layer
│   ├── providers/  # Riverpod state providers
│   ├── screens/    # Feature-specific screens (Admin, Student, Auth)
│   └── widgets/    # Reusable UI components (Common, Payment, Filters)
├── services/       # External service integrations (Firebase, Cloudinary)
└── utils/          # Helpers for formatting, validation, and permissions
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.10.4 or higher)
- Android Studio / VS Code
- Firebase Account

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/HostelManagement.git
   cd HostelManagement/hostelmanagement
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**:
   - Create a new Firebase project.
   - Add Android/iOS apps in the Firebase console.
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) and place them in their respective directories.
   - Run `flutterfire configure` if you have the CLI installed.

4. **Run the app**:
   ```bash
   flutter run
   ```

---

## 📸 Screenshots

| Student Home | Hostel Search | Admin Dashboard |
| :---: | :---: | :---: |
| ![Placeholder](https://via.placeholder.com/200x400?text=Student+Home) | ![Placeholder](https://via.placeholder.com/200x400?text=Search+Map) | ![Placeholder](https://via.placeholder.com/200x400?text=Admin+Dashboard) |

| Complaint Portal | Payment Screen | Profile Settings |
| :---: | :---: | :---: |
| ![Placeholder](https://via.placeholder.com/200x400?text=Complaints) | ![Placeholder](https://via.placeholder.com/200x400?text=Payments) | ![Placeholder](https://via.placeholder.com/200x400?text=Profile) |

---

## 🔮 Future Improvements

- [ ] **AI-Powered Matching**: Suggest hostels based on user preferences and behavior.
- [ ] **In-App Chat**: Direct communication between students and hostel admins.
- [ ] **Expense Management**: Advanced tools for hostel admins to track operational costs.
- [ ] **Analytics Dashboard**: Detailed visual reports for financial performance.
- [ ] **Multi-language Support**: Localization for international users.

---

## 👤 Author

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- LinkedIn: [Your Profile](https://linkedin.com/in/yourprofile)

---
