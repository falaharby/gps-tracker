# 🚀 Quick Start - MVVM Simplified

## Setup

```bash
flutter pub get
flutter run
```

## Project Structure

```
features/tracking/
├── model/                      # Data classes
├── data/                       # API & repository
├── viewmodel/                  # State & business logic
├── view/                       # UI widgets
└── providers.dart              # Dependency setup
```

See **MVVM_SIMPLE.md** for detailed guide.

## How It Works

1. **User taps search** → Calls `TrackingController.search()`
2. **Controller** → Calls `TrackingRepository.searchLocation()`
3. **Repository** → HTTP request to Nominatim API
4. **Response** → Parsed as `SearchResult` objects
5. **Controller** → Updates state, calls `notifyListeners()`
6. **UI** → Rebuilds with results via `Consumer<TrackingController>`

## Key Files

| File | Purpose |
|------|---------|
| `model/location_point.dart` | Data models |
| `data/tracking_repository.dart` | API calls |
| `viewmodel/tracking_controller.dart` | State management |
| `view/tracking_page.dart` | Main UI |
| `providers.dart` | Dependency injection |

## Reading State in Widget

```dart
Consumer<TrackingController>(
  builder: (context, controller, _) {
    return Text(controller.state.results.length.toString());
  },
)
```

## Calling Methods

```dart
context.read<TrackingController>().search('paris');
```

## That's It!

No over-engineering, just clean MVVM.

Read **MVVM_SIMPLE.md** for more details.

