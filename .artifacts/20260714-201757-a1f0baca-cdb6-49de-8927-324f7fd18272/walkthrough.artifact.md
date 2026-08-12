# Walkthrough - Project-Wide Clean Architecture Refactor

I have refactored the entire True Fit application to follow **Clean Architecture** principles and use **Cubit** for state management across all features.

## Architectural Changes

Each feature now has a standardized structure:

### 1. Domain Layer (Pure Business Logic)
- **Entities**: Plain Dart classes representing the data (e.g., `UserEntity`, `NotificationEntity`).
- **Repositories**: Abstract interfaces defining the available operations.
- **Use Cases**: Single-responsibility classes for each business action (e.g., `LoginUseCase`, `GetNotificationsUseCase`).

### 2. Data Layer (Implementation Details)
- **Models**: Data Transfer Objects (DTOs) that extend Entities and include JSON mapping.
- **DataSources**: Remote (API) and Local data providers (mocked for now to match current behavior).
- **Repository Implementations**: Concrete classes that implement Domain repositories using DataSources.

### 3. Presentation Layer (UI & State)
- **Cubit**: State management using the BLoC pattern.
- **State**: Clear definitions for Loading, Loaded, Error, and Success states.
- **Screens & Widgets**: Refactored to consume Cubit states via `BlocBuilder`.

## Features Refactored
- **Auth**: Fully decoupled from UI with dedicated use cases for login, registration, and guest mode.
- **Profile**: State-driven profile loading and editing.
- **Notifications**: Grouped notifications with real-time state updates (mark as read).
- **Home**: Dynamic promotions loading via HomeCubit.
- **Booking**: Consolidated state for PT sessions and Group classes.
- **Diet**: Interactive water intake tracking and meal schedule management.
- **Progress**: InBody scan data management.
- **Chat**: Conversation and message state management.
- **Subscription**: Plan management and subscription flows.

## Core Infrastructure
- **Dependency Injection**: Added `InjectionContainer` to manage the initialization and provision of all repositories, use cases, and cubits.
- **Base UseCase**: Created a common interface for all use cases to ensure consistency.

## Verification
- **Compilation**: Fixed all syntax and type errors introduced during the refactoring.
- **Static Analysis**: Ran `flutter analyze` to ensure the codebase is clean and follows best practices.
- **Functional Integrity**: Verified that the app still matches the provided React UI and maintain original functionality.
