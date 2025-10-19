
# GEMINI.md

## Project Overview

This project is a Flutter-based digital book platform named **Alhuda Library**. It enables users to read, write, and share books, with a comprehensive multi-role system (Reader, Author, Publisher, Admin). The application is built using a **Clean Architecture** with the **BLoC pattern** for state management and **GetIt** for dependency injection. The backend is powered by **Supabase**, utilizing its PostgreSQL database, authentication, and storage services. The application is designed to be cross-platform, with full support for **web, Android, and iOS**.

### Core Technologies:

*   **Frontend:** Flutter 3.8.1, Dart 3.0+
*   **Backend:** Supabase (PostgreSQL, Auth, Storage)
*   **State Management:** flutter_bloc
*   **Dependency Injection:** get_it
*   **Local Storage:** hive
*   **Rich Text Editor:** flutter_quill
*   **PDF Viewer:** syncfusion_flutter_pdfviewer
*   **Charts & Analytics:** fl_chart

## Building and Running

### Prerequisites

*   Flutter SDK 3.8.1 or higher
*   Dart 3.0+
*   Supabase account
*   Firebase account (for web hosting)
*   Git

### Setup and Running

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    ```
2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Configure Supabase credentials:**
    Update the Supabase URL and anon key in `lib/main.dart`.
4.  **Run the application:**
    ```bash
    flutter run
    ```

### Building for Production

*   **Web:**
    ```bash
    flutter build web
    ```
    To deploy to Firebase Hosting:
    ```bash
    firebase deploy --only hosting
    ```
*   **Android:**
    ```bash
    flutter build appbundle --release
    ```
*   **iOS:**
    ```bash
    flutter build ios --release
    ```

## Development Conventions

*   **Architecture:** The project follows the principles of Clean Architecture, separating the code into three layers: `data`, `domain`, and `presentation`.
*   **State Management:** The BLoC (Business Logic Component) pattern is used for managing the state of the application. Each feature has its own BLoC, which is responsible for handling business logic and emitting states.
*   **Dependency Injection:** `get_it` is used to manage dependencies throughout the application. The `lib/core/injection/injection_container.dart` file is the central place for registering all dependencies.
*   **Routing:** The application uses named routes for navigation. The routes are defined in the `lib/main.dart` file.
*   **Database:** The database schema is well-defined in `doc/skema_tabel.md`. It includes tables for users, books, chapters, reviews, reading progress, and more.
*   **Coding Style:** The project follows the official Dart and Flutter style guides. The `flutter_lints` package is used to enforce these styles.
