# JSONPlaceholder Feature Feed & Dashboard (iOS)

A high-performance, native iOS application built with modern **SwiftUI** and **Swift Concurrency**, implementing the **MVVM + Repository** architecture pattern. The application consumes the public [JSONPlaceholder API](https://jsonplaceholder.typicode.com) to present an interactive, responsive feed of posts, author profiles, and real-time discussion threads with an ambient glassmorphic design system.

---

## 📱 Visual Showcase & Screenshots

The application supports both iPhone and iPad layout form factors with responsive adaptation and ambient glassmorphism:

| iPhone Feed (Light/Dark Glass) | Search & Author Filter | Post Detail & Inline Discussion | Bottom Sheet Discussion |
| :---: | :---: | :---: | :---: |
| `iPhone 18 Pro` | `iPhone 18 Pro` | `iPhone 18 Pro` | `iPhone 18 Pro` |

> 📷 *Pre-rendered high-resolution screenshots for iPhone 18 Pro and iPad (A16) are available in the repository under:*
> `DashboardDemo/Screenshots/`

---

## 🚀 Key Features

- **Parallel Structured Concurrency (`async let`)**:
  - Fetches `/posts` and `/users` simultaneously over `URLSession`.
  - Maps author data to corresponding posts using an $O(1)$ dictionary hash lookup (`Dictionary(uniqueKeysWithValues:)`), reducing presentation mapping overhead.
- **Modern Glassmorphic Design System**:
  - Frosted acrylic glass depth (`.regularMaterial` & `.ultraThinMaterial`).
  - Continuous squircle card silhouettes (`RoundedRectangle(cornerRadius: 22, style: .continuous)`).
  - Simulated glass borders using dynamic multi-stop linear gradient strokes.
  - Multi-color diagonal gradient avatars (`[.indigo, .purple, .pink]`) with glowing soft shadows.
  - Ambient background layer featuring soft, blurred radial color orbs.
- **Search & Author Filtering Carousel**:
  - Real-time multi-attribute search filtering across post titles, post content, author display names, and `@handles`.
  - Horizontally scrollable author filter chips with selected fill states and haptic-ready spring transitions.
  - Fixed navigation bar search drawer (`.navigationBarDrawer(displayMode: .always)`) preventing the navigation title disappearance bug upon search cancellation.
- **Bookmarking & Session State**:
  - Independent bookmark toggle on every post card with animated `.contentTransition(.symbolEffect(.replace))` SF Symbol icons.
  - Navigation bar filter button to isolate bookmarked posts instantly.
- **Type-Safe Value Navigation & Post Detail**:
  - Full `NavigationStack` with type-safe `NavigationLink(value: post)` routing to `PostDetailView`.
  - Detailed author metadata card (name, email, company, catchphrase).
  - Clean typography with adjusted line spacing (`lineSpacing(6)`) for readability.
  - Inline discussion thread preview with dedicated `.task` async comment loading.
- **Modal Discussion Bottom Sheet (`CommentsSheetView`)**:
  - Interactive `.sheet(item:)` presentation with `.presentationDetents([.medium, .large])`.
  - Lazy-loaded comment threads with individual glass cards and author avatar fallbacks.
- **Tactile Micro-Interactions**:
  - Custom `ScaleButtonStyle` applying spring compression (`0.97` scale) on touch-down.
  - Pull-to-refresh (`.refreshable`) for feed updates.
  - Comprehensive state handling: `.idle`, `.loading`, `.loaded`, and `.error(String)` with retry actions.

---

## 🏛 Architecture & Project Structure

The project follows a clean separation of concerns using **MVVM + Repository Pattern**:

```text
DashboardDemo/
├── DashboardDemo.xcodeproj          # Xcode Project Configuration (Deployment Target: iOS 17.0+)
└── DashboardDemo/
    ├── DashboardDemoApp.swift       # App Entry Point (@main WindowGroup)
    ├── Models/                      # Domain & DTO Entities (nonisolated, Sendable, Codable, Hashable)
    │   ├── Post.swift               # Raw Post DTO (/posts)
    │   ├── User.swift               # Raw User & Company DTO (/users)
    │   ├── Comment.swift            # Raw Comment DTO (/comments)
    │   └── PostItem.swift           # Combined Presentation Model with computed authorInitials
    ├── Networking/                  # Network Infrastructure
    │   └── NetworkService.swift     # Generic URLSession NetworkServiceProtocol & MockNetworkService
    ├── Repositories/                # Data Orchestration
    │   └── PostRepository.swift     # PostRepositoryProtocol, parallel async let feed fetch & mocks
    ├── ViewModels/                  # State Management
    │   └── DashboardViewModel.swift # @Observable @MainActor ViewModel with DashboardViewState machine
    ├── Views/                       # SwiftUI User Interface
    │   ├── PostDashboardView.swift  # Main Feed View, Search, Filter Carousel, Ambient Background
    │   ├── PostDetailView.swift     # Dedicated Post Detail Screen with Inline Comments
    │   └── Components/
    │       ├── PostCardView.swift   # Glassmorphic Post Card with Halo Bookmark & Discussion Pill
    │       ├── FilterChip.swift     # Acrylic Author Filter Chip with Active/Inactive states
    │       ├── CommentsSheetView.swift # Detented Modal Bottom Sheet for Comments
    │       └── ScaleButtonStyle.swift  # Reusable Tactile Spring Button Style
    └── Screenshots/                 # Device captures for iPhone 18 Pro & iPad
```

### Layer Responsibilities

1. **Models Layer**: Conforms to `Identifiable`, `Codable`, `Sendable`, `Equatable`, and `Hashable`. DTOs are declared `nonisolated` to ensure full compliance with Swift 6 strict concurrency checks without accidental actor-isolation leakage.
2. **Networking Layer**: `NetworkServiceProtocol` handles generic decoding, URL request building, and error classification (`NetworkError`).
3. **Repository Layer**: `PostRepository` coordinates network calls, executes parallel `async let` operations, and transforms raw DTOs into high-level `PostItem` presentation entities.
4. **ViewModel Layer**: `DashboardViewModel` is annotated with `@Observable` and isolated to `@MainActor`. It provides deterministic state transitions (`DashboardViewState`) and handles search query debouncing, author selection, bookmark toggling, and comment sheet presentation.
5. **Views Layer**: Purely declarative and modular SwiftUI views. Child subviews remain stateless and delegate user intents back to the ViewModel or parent containers.

---

## ⚙️ System Requirements & Simulator Recommendations

### Prerequisites

| Tool / Requirement | Minimum Supported | Recommended / Tested Environment |
| :--- | :--- | :--- |
| **macOS** | macOS 14.5 Sonoma | macOS 15+ / macOS 26+ |
| **Xcode** | Xcode 16.0 | **Xcode 27.0** (Build `27A266a`) |
| **Swift Toolchain** | Swift 5.10 / Swift 6.0 | **Swift 6.4** |
| **Deployment Target** | **iOS 17.0** (`IPHONEOS_DEPLOYMENT_TARGET = 17.0`) | iOS 18.0 - iOS 27.0 |

### Recommended Simulator Devices & OS

To experience the full design system (including glassmorphic materials, spring animations, and native search drawer anchoring), run the app on the following simulator configurations:

#### 📱 Primary iPhone Simulator (Recommended)
- **Device**: **iPhone 18 Pro** (or **iPhone 16 Pro** / **iPhone 17 Pro**)
- **OS Version**: **iOS 27.0** (or **iOS 18.1 / 18.2 / 18.4 / 18.5**)
- **Simulator Identifier Example**: `iPhone 18 Pro` (`F0E88182-A8B1-4839-948A-C77B659D8BDC`)

#### 💻 Tablet / iPad Simulator
- **Device**: **iPad (A16)** or **iPad Pro 11-inch (M4 / M5)**
- **OS Version**: **iOS 27.0** or **iOS 18.x**

> **Note on OS Compatibility**: The project's deployment target is **iOS 17.0+**. Any simulator device running **iOS 17.0 or later** is fully supported and compatible with all modern SwiftUI APIs used (such as `@Observable`, `.navigationDestination(for:)`, and `.presentationDetents`).

---

## 🛠 Setup & Run Instructions

### Option 1: Running with Xcode (GUI)

1. **Open the Project**:
   Double-click `DashboardDemo.xcodeproj` or open via Terminal:
   ```bash
   open /Users/thinkpalm/MyWorkspace/iOSProjects/DashboardDemo/DashboardDemo.xcodeproj
   ```
2. **Select the Scheme**:
   In the Xcode top toolbar, verify that the scheme **`DashboardDemo`** is selected.
3. **Choose a Simulator**:
   Select your target simulator from the device dropdown:
   - **`iPhone 18 Pro`** with **iOS 27.0** (or `iPhone 16 Pro` with `iOS 18.x`).
4. **Build & Run**:
   - Press **`Cmd + R`** (or click the **▶ Run** button).
   - The simulator will boot automatically and launch the feature feed.

---

### Option 2: Running via Terminal / Command Line (`xcodebuild` & `simctl`)

You can build, install, and run the application completely from the terminal without launching the Xcode editor:

#### Step 1: Boot the Target Simulator
Boot your preferred simulator (e.g. `iPhone 18 Pro` running iOS 27.0):
```bash
# Boot the simulator device
xcrun simctl boot "iPhone 18 Pro"

# Open the Simulator application window
open -a Simulator
```

#### Step 2: Build the Application
Compile the project for the simulator destination:
```bash
cd /Users/thinkpalm/MyWorkspace/iOSProjects/DashboardDemo

xcodebuild -scheme DashboardDemo \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro,OS=27.0' \
  clean build CODE_SIGNING_ALLOWED=NO
```
*(Alternatively, use `-destination 'generic/platform=iOS Simulator'` to build against the generic simulator destination).*

#### Step 3: Install & Launch the App
Locate the built `.app` bundle from DerivedData and deploy it directly into the running simulator:
```bash
# Locate the built application bundle
APP_BUNDLE=$(find ~/Library/Developer/Xcode/DerivedData/DashboardDemo-*/Build/Products/Debug-iphonesimulator -name "DashboardDemo.app" | head -n 1)

# Install onto the booted simulator
xcrun simctl install booted "$APP_BUNDLE"

# Launch the app by Bundle Identifier
xcrun simctl launch booted com.demo.DashboardDemo
```

To view live application logs in your terminal:
```bash
xcrun simctl spawn booted log stream --predicate 'process == "DashboardDemo"' --level debug
```

---

## 🧪 Testing & Verification

The architecture is built for complete testability using protocol-based dependency injection:

- `NetworkServiceProtocol` allows swapping real network calls with `MockNetworkService`.
- `PostRepositoryProtocol` allows swapping repository responses with `MockPostRepository`.
- All models conform to `Equatable` and `Sendable` for deterministic unit testing.

### Automated Test Coverage
The project includes automated assertions covering:
1. **JSON Decoding**: Validates parsing of `User`, `Company`, and `Comment` JSON payloads.
2. **Repository Parallelism**: Asserts combined `[PostItem]` output from separate `/posts` and `/users` mocks with verified author ID linkage.
3. **ViewModel Filtering**:
   - Case-insensitive search across title, body, author name, and username.
   - Author ID isolation via carousel selection.
   - Bookmarked-only feed filtering.
   - Distinct, sorted author list extraction.
4. **Comment Loading Lifecycle**: Validates loading states and error handling during comment retrieval.

---

## 📋 Resolved Edge Cases & Troubleshooting

### 1. Navigation Title Disappearing on Search Dismissal
- **Symptom**: When dismissing or tapping "Cancel" on the native search bar, the large "Dashboard" navigation title disappeared or collapsed unexpectedly.
- **Root Cause**: The root container in `NavigationStack` had intermediate background layers and a horizontal author carousel before the vertical scroll view, preventing `UINavigationBar` from calculating scroll offsets accurately.
- **Resolution**:
  - Anchored `ScrollView` directly at the top level of `NavigationStack`.
  - Moved background ambient circles to `.background(ambientBackgroundLayer)`.
  - Configured `.searchable` with explicit placement: `.navigationBarDrawer(displayMode: .always)`.
  - Added `.navigationBarTitleDisplayMode(.large)` to stabilize navigation bar height transitions.

### 2. Swift 6 Concurrency & Actor Isolation
- **Symptom**: `main actor-isolated conformance of 'User' to 'Decodable' cannot satisfy conformance requirement for a 'Sendable' type parameter`.
- **Resolution**: Marked all network transfer entities (`Post`, `User`, `Company`, `Comment`, `PostItem`) with `nonisolated` so protocol conformances are not tied to `@MainActor`, while keeping `DashboardViewModel` cleanly isolated to `@MainActor`.

---

## 📄 License & Attribution

- Built as a demonstration of modern native iOS engineering best practices.
- Data provided by [JSONPlaceholder](https://jsonplaceholder.typicode.com).
- Icons provided by Apple [SF Symbols](https://developer.apple.com/sf-symbols/).
