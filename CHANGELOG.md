# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- GitHub Actions CI/CD pipeline for automated build and test
- Security policy with responsible disclosure process
- Code of Conduct for community guidelines

### Changed
- Migrated from SwiftData to API-driven architecture
- Replaced all local SwiftData views with API-backed Backend views

### Removed
- All SwiftData models and local storage
- Legacy SwiftUI views (HomeView, AlbumView, DiaryView, etc.)

---

## [1.0.0] - 2025-07-03

### Added

#### Authentication
- JWT-based authentication with access and refresh tokens
- User registration with invite code system
- Secure token storage using iOS Keychain
- Automatic token refresh on expiration
- Login, register, logout, and profile management

#### Architecture
- Clean Architecture implementation with Domain/Data/ViewModels/Views layers
- Dependency Injection container for centralized service management
- Repository pattern with protocol-based abstractions
- MVVM pattern with Backend views for navigation encapsulation

#### Domain Layer
- **Entities**: User, PartnerProfile, Relationship, Photo, DailyTask, QuestionOfTheDay, MoodEntry, DiaryEntry, TimeCapsule, Place, ImportantDate, Collage, Answer, MoodStats, PartnerLike, TaskTemplate, QuestionTemplate
- **Repository Protocols**: Auth, Album, Task, Question, Diary, Mood, Place, Capsule, Date
- **Use Cases**: Home, Album, Task, Question, Diary, Mood, Place, Capsule, Date

#### Data Layer
- **API Client**: URLSession-based HTTP client with async/await support
- **DTOs**: AlbumDTOs, AuthDTOs, CapsuleDTOs, DateDTOs, DiaryDTOs, MoodDTOs, PlaceDTOs, QuestionDTOs, TaskDTOs
- **Mappers**: DataMapper for API-to-Entity transformation
- **Repositories**: Full implementations for all repository protocols
- **Multipart Upload**: Support for photo and media file uploads

#### Views
- **Authentication**: LoginView, ProfileSetupView, PartnerSearchView, PartnerCardView
- **Navigation**: MainTabViewBackend with 5 tabs
- **Home**: Relationship counter, upcoming dates, today's task/question/mood
- **Album**: Photo grid, year filtering, collage creation
- **Tasks**: Daily tasks with completion and photo attachment
- **Questions**: Questions of the day with answer submission
- **Diary**: Diary entry management
- **Time Capsule**: Capsule creation, opening, and history
- **Map**: Places management with location tracking
- **More**: Additional app features
- **Poster Generator**: Poster creation from photos

#### CI/CD
- GitHub Actions workflow for automated build and test
- iOS Simulator testing on push and pull requests
- Code coverage reporting
- Test result artifact upload

#### Documentation
- README.md with project overview, features, and architecture
- SECURITY.md with vulnerability reporting guidelines
- CODE_OF_CONDUCT.md for community standards
- CONTRIBUTING.md with contribution guidelines
- CHANGELOG.md for version history

### Removed

#### SwiftData (replaced by API)
- `Models/Models.swift` — All local SwiftData models (202 lines)
- `Views/HomeView.swift` — Home screen (810 lines)
- `Views/AlbumView.swift` — Album screen (366 lines)
- `Views/DiaryView.swift` — Diary screen (417 lines)
- `Views/QuestionsView.swift` — Questions screen (415 lines)
- `Views/TasksView.swift` — Tasks screen (307 lines)
- `Views/TimeCapsuleView.swift` — Time Capsule screen (393 lines)
- `Views/MapView.swift` — Map screen (307 lines)
- `Views/MoreView.swift` — More screen (299 lines)
- `Views/PosterGeneratorView.swift` — Poster Generator (308 lines)
- `Views/MainTabView.swift` — Tab navigation (61 lines)

### Technical Improvements

- **Networking**: Full async/await support with URLSession
- **Error Handling**: Comprehensive API error types with localized messages
- **Data Encoding**: JSONDecoder/JSONEncoder with snake_case and ISO8601 strategies
- **Security**: Keychain-based token storage, HTTPS-only communication
- **Performance**: Concurrent async requests for home data fetching

---

## Version History

| Version | Date | Description |
|---------|------|-------------|
| 1.0.0 | 2025-07-03 | Initial release with API-driven architecture |
| 0.1.0 | 2025-06-xx | Initial SwiftData-based prototype |

---

## Notes

This project was migrated from a SwiftData-based local storage approach to a fully API-driven architecture, enabling real-time synchronization between partners and scalable data management.
