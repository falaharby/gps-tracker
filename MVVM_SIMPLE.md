# 📱 MVVM Architecture Guide (Simplified)

Simple MVVM pattern without over-engineering.

## Structure

```
features/tracking/
├── model/                      # Data models
│   └── location_point.dart     # LocationPoint, SearchResult
│
├── data/                       # Data access layer
│   └── tracking_repository.dart # API calls, caching
│
├── viewmodel/                  # Business logic & state
│   └── tracking_controller.dart # ChangeNotifier controller
│
├── view/                       # UI layer
│   ├── tracking_page.dart      # Main page
│   └── widgets/
│       └── search_results_widget.dart  # Reusable widget
│
└── providers.dart              # Dependency setup
```

## Layer Descriptions

### 1. **model/** - Data Models
Plain Dart classes that represent data.
- `LocationPoint` - GPS location with latitude, longitude, timestamp
- `SearchResult` - Search result with display name and coordinates

```dart
class SearchResult {
  final String displayName;
  final double latitude;
  final double longitude;
  
  factory SearchResult.fromJson(Map<String, dynamic> json) { ... }
}
```

### 2. **data/** - Repository
Handles API calls, caching, error handling.

```dart
class TrackingRepository {
  Future<List<SearchResult>> searchLocation(String query) { ... }
}
```

**What it does:**
- Makes HTTP requests
- Caches results
- Rate limiting
- Error handling

### 3. **viewmodel/** - Controller
Business logic and UI state management using ChangeNotifier.

```dart
class TrackingController extends ChangeNotifier {
  SearchState state;
  
  Future<void> search(String query) { ... }
  void clearResults() { ... }
}
```

**What it does:**
- Manages UI state
- Calls repository methods
- Notifies listeners of state changes

### 4. **view/** - UI Widgets
Flutter widgets that display data and respond to user input.

```dart
class TrackingPage extends StatefulWidget { ... }
class SearchResultsWidget extends StatelessWidget { ... }
```

**What it does:**
- Displays UI using state from controller
- Handles user interactions
- Calls controller methods on user action

### 5. **providers.dart** - Dependency Setup
Simple dependency injection.

```dart
List<ChangeNotifierProvider> trackingProviders() {
  return [
    ChangeNotifierProvider<TrackingController>(
      create: (_) => TrackingController(
        repository: TrackingRepository(httpClient: http.Client()),
      ),
    ),
  ];
}
```

## Data Flow

```
USER TAPS SEARCH
    ↓
TrackingPage (view)
    ↓ context.read<TrackingController>().search(query)
TrackingController (viewmodel)
    ↓ await repository.searchLocation()
TrackingRepository (data)
    ↓ HTTP GET to Nominatim API
    ↓ Parse JSON response
    ↓ Return List<SearchResult>
    ↓ Controller updates state
    ↓ state = state.copyWith(results: results)
    ↓ notifyListeners()
    ↓
Consumer<TrackingController> rebuilds
    ↓
SearchResultsWidget displays results
    ↓
USER SEES RESULTS
```

## Usage in Widgets

### Reading State
```dart
Consumer<TrackingController>(
  builder: (context, controller, _) {
    return Text(controller.state.results.length.toString());
  },
)
```

### Calling Methods
```dart
FloatingActionButton(
  onPressed: () {
    context.read<TrackingController>().search('paris');
  },
)
```

## Key Concepts

### ChangeNotifier Pattern
```dart
class TrackingController extends ChangeNotifier {
  SearchState _state = SearchState();
  
  SearchState get state => _state;
  
  void updateState() {
    _state = newState;
    notifyListeners();  // Trigger UI rebuild
  }
}
```

### Immutable State (copyWith)
```dart
state = state.copyWith(
  isLoading: false,
  results: results,
  error: null,
);
```

### Consumer Widget
```dart
Consumer<TrackingController>(
  builder: (context, controller, child) {
    // Rebuilds when controller.state changes
  },
)
```

## Adding a New Feature

1. **Create Model** in `model/`
2. **Create Repository** in `data/` (handles API)
3. **Create Controller** in `viewmodel/` (extends ChangeNotifier)
4. **Create Widget** in `view/`
5. **Register in providers.dart**

## Testing

### Unit Test Repository
```dart
test('searchLocation returns results', () async {
  final repo = TrackingRepository(httpClient: mockClient);
  final results = await repo.searchLocation('paris');
  expect(results, isNotEmpty);
});
```

### Unit Test Controller
```dart
test('search updates state', () async {
  final controller = TrackingController(repository: mockRepo);
  await controller.search('paris');
  expect(controller.state.results, isNotEmpty);
});
```

### Widget Test
```dart
testWidgets('Tracking page shows search', (tester) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: trackingProviders(),
      child: MaterialApp(home: TrackingPage()),
    ),
  );
  expect(find.byType(TextField), findsOneWidget);
});
```

## DO's ✅

- Use `Consumer<Controller>` to watch provider changes
- Use `context.read<Controller>()` to call methods
- Call `notifyListeners()` after state changes
- Use `copyWith()` for immutable state updates
- Keep UI logic in view layer
- Keep business logic in controller
- Keep data access in repository

## DON'Ts ❌

- Don't update state in widget build()
- Don't forget `notifyListeners()`
- Don't mutate state directly
- Don't put API calls in widgets
- Don't mix layers (data access in UI)
- Don't use `watch()` for one-time reads
- Don't call `read()` for reactive updates

## That's It!

Simple, clean MVVM without over-engineering. Easy to understand, easy to test, easy to extend.
