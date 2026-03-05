# RemeDi

RemeDi is a cross-platform medication reminder and management application built with Flutter. It helps users track their medications, schedule reminders, log doses, and monitor adherence over time.

---

## Tech Stack

![Flutter](https://img.shields.io/badge/Flutter-3.6.2-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=flat&logo=firebase&logoColor=black)
![Firestore](https://img.shields.io/badge/Firestore-NoSQL-orange?style=flat)
![Riverpod](https://img.shields.io/badge/Riverpod-2.6.1-00BFA5?style=flat)
![Supabase](https://img.shields.io/badge/Supabase-2.10.3-3ECF8E?style=flat&logo=supabase&logoColor=white)
![Cloudinary](https://img.shields.io/badge/Cloudinary-Image_Storage-3448C5?style=flat)

---

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Data Models](#data-models)
- [Getting Started](#getting-started)
- [Environment Variables](#environment-variables)
- [Dependencies](#dependencies)

---

## Features

**Medication Management**

- Add, edit, and delete medications with full detail including dosage, form, unit, and color tag.
- Attach images to medications using the device camera or gallery, stored via Cloudinary.
- Track current stock levels and set refill threshold alerts.
- Configure overdose safety limits: maximum daily doses and minimum interval between doses.

**Reminder Scheduling**

- Set one or more reminder times per medication.
- Choose from multiple frequency types: daily, specific days of the week, interval-based, or as-needed.
- Reminders are delivered as local notifications with full timezone support.
- Compatible with Android 13+ exact alarm permission requirements.

**Dose Logging and History**

- Log each dose as taken, missed, skipped, or upcoming.
- View dose history on an interactive calendar.
- Access daily summaries with adherence statistics.
- Filter and browse past dose records with timestamps and status indicators.

**Dashboard**

- See all of today's scheduled medications at a glance.
- View upcoming doses sorted by scheduled time.
- Navigate quickly to any medication detail or dose log.

**User Profile**

- Register and authenticate with email and password via Firebase Auth.
- Update display name, phone number, date of birth, and bio.
- Upload and update profile photo, stored in Cloudinary.
- Reset password via email.

---

## Architecture

RemeDi follows Clean Architecture principles, organized into three main layers within each feature module: Domain, Data, and Presentation.

```
Presentation Layer
    Screens and Widgets
    Riverpod Providers (StateNotifier, AsyncNotifier)
         |
Domain Layer
    Entities (User, Medication, DoseLog)
    Repository Interfaces (abstract)
    Use Cases
         |
Data Layer
    Repository Implementations
    Remote Data Sources (Firebase Firestore)
    Data Models (Firestore serialization)

Core Layer (shared across features)
    Services (NotificationService, CloudinaryService)
    Network (FirestoreDataSource)
    Error Handling (Failure types using fpdart)
    Constants and Configuration

Shared Layer
    Theme and Styling
    Layout Templates
    Reusable Widgets
```

**Data Flow**

UI triggers user actions, which are passed to Riverpod providers. Providers invoke use cases, which call repository interfaces. Repository implementations communicate with Firebase Firestore through a shared data source. Results are returned as `Either<Failure, T>` using the fpdart package, making error handling explicit at every layer.

**State Management**

State is managed exclusively through Flutter Riverpod. Each feature exposes one or more `StateNotifier` or `AsyncNotifier` providers. The UI rebuilds reactively using `ConsumerWidget` and `ConsumerStatefulWidget`.

**Navigation**

GoRouter handles all navigation with named routes, path parameters, and redirect guards for authentication state.

---

## Project Structure

```
lib/
  core/
    constants/          # App-wide constants
    errors/             # Failure types and error handling
    network/            # Firestore base data source
    services/           # NotificationService, CloudinaryService
  features/
    authentication/     # Sign in, Sign up, password reset
      data/             # Models, data sources, repository impl
      domain/           # Entities, repository interface, use cases
      presentation/     # Screens, widgets, providers
    medications/        # Medication CRUD and scheduling
    history/            # Dose logs and adherence tracking
    dashboard/          # Home screen and today's overview
    profile/            # User profile management
  shared/
    styles/             # Theme configuration (colors, typography)
    layout/             # Scaffold and layout templates
    widgets/            # Common reusable widgets (shimmer, badges, etc.)
  main.dart             # App entry point and initialization
  firebase_options.dart # Generated Firebase configuration
```

---

## Data Models

**User**

| Field | Type | Description |
|---|---|---|
| id | String | Firebase Auth UID |
| email | String | User email address |
| displayName | String | User display name |
| phoneNumber | String | Optional phone number |
| photoUrl | String | Cloudinary image URL |
| dateOfBirth | DateTime | Optional date of birth |
| bio | String | Optional profile bio |
| createdAt | DateTime | Account creation timestamp |
| updatedAt | DateTime | Last profile update timestamp |

**Medication**

| Field | Type | Description |
|---|---|---|
| id | String | Unique medication ID |
| userId | String | Owner user ID |
| name | String | Medication name |
| dosage | double | Dose amount |
| unit | String | Unit (mg, ml, pill, etc.) |
| type | String | Form type (Tablet, Liquid, etc.) |
| color | String | Hex color tag |
| currentStock | int | Current stock count |
| refillThreshold | int | Refill alert threshold |
| frequencyType | String | daily, specificDays, interval, asNeeded |
| frequencyDays | List | Days of week for specificDays type |
| interval | int | Hours between doses for interval type |
| reminderTimes | List | Scheduled reminder times (HH:mm) |
| startDate | DateTime | Medication start date |
| endDate | DateTime | Optional end date |
| notes | String | Optional notes |
| imageUrl | String | Optional Cloudinary image URL |
| maxDailyDoses | int | Optional overdose limit |
| minIntervalMinutes | int | Optional minimum interval between doses |

**DoseLog**

| Field | Type | Description |
|---|---|---|
| id | String | Unique dose log ID |
| medicationId | String | Reference to medication |
| medicationName | String | Snapshot of medication name |
| dosage | double | Snapshot of dose amount |
| unit | String | Snapshot of unit |
| form | String | Snapshot of medication form |
| scheduledTime | DateTime | When the dose was scheduled |
| takenTime | DateTime | When the dose was actually taken (nullable) |
| status | String | taken, missed, skipped, upcoming |
| notes | String | Optional dose notes |
| colorTag | String | Hex color from medication |
| createdAt | DateTime | Log creation timestamp |

---

## Getting Started

**Prerequisites**

- Flutter SDK 3.6.2 or higher
- Dart 3.x
- A Firebase project with Authentication and Firestore enabled
- A Cloudinary account for image storage

**Installation**

1. Clone the repository:

```
git clone https://github.com/tekle-eyesus/RemeDi.git
cd RemeDi
```

2. Install dependencies:

```
flutter pub get
```

3. Configure Firebase by running the FlutterFire CLI and replacing `firebase_options.dart`:

```
flutterfire configure
```

4. Copy the environment variables template and fill in your values:

```
cp .env.example .env
```

5. Run the app:

```
flutter run
```

---

## Environment Variables

| Variable | Description |
|---|---|
| CLOUDINARY_CLOUD_NAME | Your Cloudinary cloud name |
| CLOUDINARY_PRESET_NAME | Your Cloudinary unsigned upload preset |

---

## Dependencies

| Package | Version | Purpose |
|---|---|---|
| flutter_riverpod | 2.6.1 | State management |
| firebase_core | 4.2.1 | Firebase initialization |
| firebase_auth | 6.1.2 | User authentication |
| cloud_firestore | 6.1.0 | NoSQL cloud database |
| firebase_storage | 13.0.4 | Cloud file storage |
| firebase_messaging | 16.0.4 | Push notifications |
| supabase_flutter | 2.10.3 | Backend-as-a-service |
| go_router | 16.1.0 | Declarative routing |
| flutter_local_notifications | 19.5.0 | Local scheduled notifications |
| timezone | 0.10.0 | Timezone handling |
| google_fonts | 6.3.0 | Poppins typography |
| syncfusion_flutter_calendar | 29.1.38 | Calendar UI components |
| table_calendar | 3.0.9 | Interactive calendar |
| cached_network_image | 3.4.1 | Network image caching |
| image_picker | 1.2.0 | Camera and gallery access |
| http | 1.6.0 | HTTP requests |
| fpdart | 1.2.0 | Functional error handling (Either) |
| formz | 0.8.0 | Form validation |
| uuid | 4.5.2 | Unique ID generation |
| intl | 0.18.1 | Internationalization and date formatting |
| shimmer | 3.0.0 | Loading shimmer effects |

---

## License

This project is open source. See the LICENSE file for details.
