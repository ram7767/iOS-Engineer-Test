# RemoteRecruit – Job Browser App

**Author:** Ratnakaram Rama Narasimha Raju  
[GitHub](https://github.com/ram7767) · ramnarasimharaju@gmail.com

---

A production-quality iOS app that lets users browse, search, filter, and save remote job listings from the [Remotive API](https://remotive.com/api/remote-jobs). Built with SwiftUI, MVVM, and full protocol-based dependency injection.

---

## Quick Start

```bash
git clone https://github.com/ram7767/iOS-Engineer-Test.git
cd iOS-Engineer-Test
open iOS-Engineer-Test.xcodeproj
```

Press **⌘R** to build and run — no API key or additional setup required.

---

## Architecture

**MVVM** with clean dependency injection from app entry point down:

```
iOS-Engineer-Test/
├── Models/         Job.swift                    — Codable data model (RemoteJob)
├── Services/       JobService.swift             — Fetch + cache from Remotive API
│                   SavedJobsService.swift        — UserDefaults persistence + Combine publisher
│                   ImageCacheService.swift       — Actor-based async image cache (NSCache)
├── ViewModels/     JobListViewModel.swift        — Pagination, search, filter state
│                   JobDetailViewModel.swift      — Detail + save/unsave toggle
│                   SavedJobsViewModel.swift      — Saved list state
└── Views/          JobListView + JobDetailView + SavedJobsView + Components
```

Key decisions:
- All services are behind protocols — full mock injection in tests, zero real network calls
- `@MainActor` on every ViewModel — thread-safe `@Published` mutations
- Client-side pagination (Remotive API is a single-endpoint API; filtering, search, and pagination are all local)
- `CurrentValueSubject` in `SavedJobsService` — reactive save-state propagation to list and detail screens

---

## Features

| Feature | Status |
|---------|--------|
| Job listing with title, company, location, salary | ✅ |
| Search by title, company, or category (debounced) | ✅ |
| Category filter chips (horizontal scroll) | ✅ |
| Pagination — 10 jobs per page, infinite scroll | ✅ |
| Async company logo loading with 50 MB in-memory cache | ✅ |
| Job detail screen with description, metadata, apply link | ✅ |
| Save / unsave jobs (UserDefaults, persists across launches) | ✅ |
| Saved jobs screen with swipe-to-delete | ✅ |
| Share job via native share sheet | ✅ |
| Pull-to-refresh | ✅ |
| Loading / Empty / Error state views | ✅ |
| Unit tests — ViewModels, Services, Models | ✅ |

---

## Running Tests

**Xcode:** Press **⌘U** or go to **Product → Test**

**Command line:**
```bash
xcodebuild test \
  -scheme "iOS-Engineer-Test" \
  -destination "platform=iOS Simulator,name=iPhone 17,OS=26.5" \
  -enableCodeCoverage YES \
  -resultBundlePath /tmp/TestResults.xcresult
```

---

## Code Coverage

**View the report (after running tests):**
```bash
xcrun xccov view --report /tmp/TestResults.xcresult
```

**Overall coverage report:**

| File | Coverage |
|------|----------|
| `JobDetailViewModel.swift` | 100% |
| `SavedJobsViewModel.swift` | 100% |
| `SavedJobsService.swift` | 100% |
| `iOS_Engineer_TestApp.swift` | 100% |
| `JobListViewModel.swift` | 97% |
| `JobService.swift` | 97% |
| `JobDetailView.swift` | 97% |
| `StateView.swift` | 98% |
| `JobCardView.swift` | 98% |
| `Job.swift` | 96% |
| `ImageCacheService.swift` | 93% |
| `CategoryFilterView.swift` | 93% |
| `AsyncImageView.swift` | 93% |
| `SavedJobsView.swift` | 91% |
| `JobListView.swift` | 86% |
| **Total (app target)** | **94%** |

> SwiftUI view bodies are covered by rendering them via `UIHostingController` in unit tests — no ViewInspector dependency required.

**Test suite:** 95 tests, 0 failures

| Test File | What it covers |
|-----------|---------------|
| `JobModelTests` | Decoding, computed properties, date parsing, Hashable |
| `JobListViewModelTests` | Load, pagination, search, filter, error/empty states, refresh |
| `JobDetailViewModelTests` | Save/unsave toggle, publisher sync, share text, logo URL |
| `SavedJobsViewModelTests` | Load, remove, isSaved, multiple jobs |
| `SavedJobsServiceTests` | CRUD, deduplication, UserDefaults persistence, publisher |
| `JobServiceTests` | Fetch+decode, caching, server errors, bad JSON |
| `ImageCacheServiceTests` | Invalid URL, clearCache, concurrent requests |
| `ViewRenderingTests` | Renders all SwiftUI views via UIHostingController; covers view bodies, strippingHTML |

---

## Assumptions

1. **Pagination is client-side.** The Remotive API returns all jobs in one response; the app slices into pages of 10.
2. **Client-side filtering and search.** The API ignores `?search=` and `?category=` query params — all filtering is done in-memory.
3. **UserDefaults for persistence.** Sufficient for the scope; `SavedJobsServiceProtocol` makes it trivial to swap in CoreData.
4. **HTML descriptions.** The API returns HTML-formatted text, stripped via `NSAttributedString` with regex fallback.
5. **No authentication.** The Remotive public API requires no API key.
