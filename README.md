# Card Organizer App

A Flutter application that allows users to organize playing cards into folders based on their suits (Hearts, Spades, Diamonds, and Clubs). This app demonstrates local data persistence using SQLite, relational database design with foreign keys, and advanced UI state management.

## Core Features
* **Persistent Storage:** Utilizes `sqflite` for robust local database management.
* **Relational Data:** Implements foreign keys with `ON DELETE CASCADE` to ensure referential integrity between Folders and Cards.
* **Pre-populated Data:** Automatically initializes the database with 4 suit folders and a standard 52-card deck on the first launch.
* **Image Handling:** Smoothly renders local `.png` asset images for cards and folders using a dedicated `CardImage` widget with broken-image fallbacks.
* **Responsive UI:** Adapts the folder grid layout based on screen width constraints using a `LayoutBuilder`.
* **Full CRUD:** Users can add new cards, edit existing card details (including reassigning them to different folders), and safely delete records.

---

## 🌟 Bonus Features Implemented

### 1. Drag & Drop Reordering (Advanced)
We implemented full drag-and-drop functionality allowing users to custom-sort cards within any folder.
* **Database Schema:** Added an `order_index` (INTEGER) column to the `cards` table.
* **UI Implementation:** Upgraded the standard list to a `ReorderableListView` in `cards_screen.dart`.
* **State Management:** When a user drags a card, the app calculates the new `order_index` for the affected cards, updates the UI immediately for a snappy feel, and dispatches a batch update (`updateCardOrders`) via the `CardRepository` to persist the new order in the SQLite database.

### 2. Custom Card Themes (Creative - Schema Foundation)
We laid the database groundwork for customizable app themes.
* **Database Schema:** Created a new `themes` table in `database_helper.dart` with `id`, `theme_name`, and `is_active` columns.
* **Pre-population:** The database initializes with a 'Default Light' theme set to active. This fulfills the data modeling requirement for the themes feature, setting up a clean architecture for future UI styling integration.

---

## Project Architecture
This project strictly adheres to the **Repository Pattern** to separate UI logic from data access:
* **`/models`:** Contains `folder.dart` and `card.dart` for type-safe data serialization (`toMap` / `fromMap`).
* **`/repositories`:** Centralizes database queries in `folder_repository.dart` and `card_repository.dart`.
* **`/screens`:** Contains stateful UI widgets (`folders_screen.dart`, `cards_screen.dart`, `card_form_screen.dart`).
* **`/widgets`:** Contains reusable UI components like `card_image.dart`.

## Setup Instructions
1. Clone the repository.
2. Ensure you have a standard 52-card asset pack located in `assets/cards/` (e.g., `hearts_ace.png`).
3. Run `flutter pub get` to install dependencies.
4. Run `flutter run` on an emulator or physical device. *(Note: SQLite functionality is not supported on Flutter Web).*