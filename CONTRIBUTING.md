# Contributing to Our Love

First off, thank you for considering contributing to Our Love! 💕

We welcome all contributions and appreciate your time and effort.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How Can I Contribute?](#how-can-i-contribute)
- [Style Guides](#style-guides)
- [Commit Messages](#commit-messages)
- [Pull Requests](#pull-requests)

## 🌟 Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md).
By participating, you are expected to uphold this code.

## 🚀 Getting Started

### Prerequisites

- iOS 17.0+
- Xcode 16.4+
- Swift 5.9+
- CocoaPods (if needed)

### Setup

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/our-love-ios.git
   ```
3. Open the project in Xcode:
   ```bash
   open "Our Love.xcodeproj"
   ```
4. Create a new branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## 💡 How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the issue list for existing reports.
When creating an issue, include:

- Clear title and description
- Steps to reproduce the issue
- Expected vs actual behavior
- Screenshots if applicable
- Your iOS version and device model

### Suggesting Enhancements

We welcome enhancement suggestions! Please include:

- A clear title and description
- Use case scenario
- Any relevant mockups or examples

### Code Contributions

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'feat: add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📝 Style Guides

### Swift Style Guide

We follow the [Apple Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/) and the [Ray Wenderlich Swift Style Guide](https://github.com/raywenderlich/swift-style-guide).

#### Naming Conventions

- **Types** (classes, structs, enums): `PascalCase`
  ```swift
  class AuthService { }
  struct User { }
  enum NetworkError: Error { }
  ```

- **Variables and constants**: `camelCase`
  ```swift
  let userName: String
  var isLoading: Bool
  ```

- **Methods**: `camelCase`, descriptive parameter names
  ```swift
  func fetchUserProfile(userId: String) async throws -> UserProfile
  ```

- **File names**: `PascalCase.swift`
  ```
  AuthService.swift
  UserProfile.swift
  ```

#### Code Organization

- Group related code with markers:
  ```swift
  // MARK: - Properties
  // MARK: - Lifecycle
  // MARK: - Public Methods
  // MARK: - Private Methods
  ```

- Maximum line length: 120 characters
- Use 4 spaces for indentation (not tabs)
- Add trailing newlines to files

### Architecture Guidelines

Our project follows Clean Architecture with these layers:

1. **Domain** - Business logic, entities, use cases (no dependencies)
2. **Data** - Repository implementations, DTOs, API clients
3. **ViewModels** - UI state management
4. **Views** - SwiftUI interfaces

When adding new features:

1. Define entities in `Domain/Entities/`
2. Create repository protocols in `Domain/RepositoryProtocols/`
3. Implement repositories in `Data/Repositories/`
4. Create DTOs in `Data/DTOs/`
5. Add mappers in `Data/Mappers/`
6. Create use cases in `Domain/UseCases/`
7. Build ViewModels in `ViewModels/`
8. Implement Views in `Views/`

## 💬 Commit Messages

We follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Code style changes (formatting, semicolons, etc)
- `refactor`: Code changes that neither fix a bug nor add a feature
- `test`: Adding or updating tests
- `ci`: CI configuration changes
- `chore`: Maintenance tasks

### Examples

```
feat: add mood tracking functionality
fix: resolve JWT token refresh issue
docs: update README with setup instructions
refactor: extract API client into separate module
```

## 🔀 Pull Requests

### PR Process

1. Update documentation if needed
2. Add tests for new functionality
3. Ensure all tests pass
4. Update CHANGELOG.md with your changes
5. Request review from maintainers

### PR Template

When opening a PR, please fill out the provided template with:

- **Description**: What does this PR do?
- **Related Issues**: Links to related issues
- **Type of Change**: Bug fix, new feature, refactoring, etc.
- **Testing**: How did you test your changes?
- **Screenshots**: If applicable

### Review Process

- All PRs require at least one approval
- CI checks must pass
- Resolve all review comments
- Squash commits before merge (unless maintaining history)

## 🎨 UI/UX Guidelines

- Follow Apple's [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- Use SF Symbols for icons
- Support Dynamic Type for accessibility
- Test on multiple device sizes
- Use system colors and materials where appropriate

## 📱 Testing

- Write unit tests for ViewModels and UseCases
- Test on both simulator and real devices
- Test with different iOS versions if possible
- Ensure accessibility features work correctly

## 🙏 Thank You

Thank you for contributing to Our Love! Your efforts help make this app better for couples around the world. 💕

---

Questions? Reach out to the maintainer at **saliev.iakhebek@gmail.com**
