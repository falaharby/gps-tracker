# 📍 GPS Tracker App

A background-capable GPS tracking application built with Flutter.
This app records user movement at configurable time intervals, stores location data locally, and visualizes the path on a map.

---

## ⚙️ Setup

```bash
git clone https://github.com/falaharby/gps-tracker.git
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

---

## 🚀 Features

* Real-time GPS tracking (time-based)
* Background tracking support
* Configurable tracking interval & accuracy
* Start & stop tracking session
* Polyline visualization on map
* Local persistence using Hive
* MVVM architecture with service layer

---

## 🧠 Technical Overview

## 🧱 Architecture

This project uses a **MVVM (Model-View-ViewModel)** architecture combined with **Provider** for state management.

### Structure Overview

```text
View (UI)
↓
ViewModel (ChangeNotifier)
↓
Service Layer (GPS / Background)
↓
Repository
↓
Local Storage (Hive)
```

---

## ❓ Why MVVM?

MVVM is used to separate UI from business logic:

* **View** → Handles UI rendering only
* **ViewModel** → Manages state and user actions
* **Model** → Represents data structure

This ensures:

* Cleaner code structure
* Easier maintenance
* Better scalability

---

## ⚙️ State Management: Provider

State is managed using Provider with `ChangeNotifier`.

### Why Provider?

* Simple and lightweight
* Easy to integrate with MVVM
* Reactive UI updates using `notifyListeners()`
* Suitable for small to medium scale applications

---

## 📌 Summary

The combination of **MVVM + Provider** provides:

* Clear separation between UI and logic
* Reactive state updates
* Simple and maintainable architecture without overengineering

---

## 🛰️ Tracking Strategy

The app uses a **time-based tracking approach**, meaning:

> Location is captured at a fixed interval (e.g., every X seconds), regardless of movement.

This approach ensures:

* Consistent data collection
* Better compatibility with background execution
* Predictable tracking behavior

---

## ⚙️ Configurable Settings

Users can configure:

* **Tracking Interval** (e.g., 3s, 5s, 10s)
* **Location Accuracy** (low, medium, high)

This allows balancing between:

* Battery usage
* Tracking precision

---

## 🔄 Background Tracking

Tracking logic is handled inside:

```text
background_service_init.dart
```

The app uses flutter_background_service to ensure:

* Tracking continues when app is minimized
* Service runs independently of UI lifecycle
* Reliable data collection over time

---

## 📉 Data Quality Handling

To prevent noisy GPS data:

* Low-accuracy points can be filtered
* Tracking interval prevents excessive data spam

---

## 🗺️ Map Visualization

The app uses flutter_map to render:

* User path as polyline
* Real-time updates from stored points

---

## 💾 Local Storage

Data is stored using Hive for:

* Fast writes (important for frequent tracking)
* Lightweight structure
* Efficient retrieval for map rendering

Each point contains:

* Latitude
* Longitude
* Timestamp

---

## 🔁 Tracking Lifecycle

1. User starts tracking
2. Background service is initialized
3. At each interval:

   * Location is fetched
   * Data is stored locally
   * UI updates (if active)
4. User stops tracking
5. Service stops safely

---

## ⚠️ Trade-offs

### Time-based tracking

Pros:

* Consistent sampling
* Works well in background

Cons:

* Can record redundant points when user is stationary
* Higher battery usage if interval too small

---

## 📌 Future Improvements

* Smart filtering (ignore stationary points)
* Session-based tracking grouping
* Route smoothing algorithm
* Export tracking data (GPX / JSON)

---

## 🧪 Key Engineering Decisions

* Chose time-based tracking for background reliability
* Used configurable interval for flexibility
* Avoided overengineering architecture
* Focused on real-world tracking behavior

---

## 👨‍💻 Author

Falah Hikamudin Arby
