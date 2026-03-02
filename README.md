<a id="readme-top"></a>

<br />
<div align="center">
  <a href="https://github.com/GalaxiMaster/Exercise-App">
    <img src="https://cdn.creazilla.com/icons/3253780/flutter-icon-lg.png" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">Exercise App</h3>

  <p align="center">
Exercise App is a data-driven platform for tracking and customizing workouts and study routines, helping users optimize performance and consistency.    <br />
    <a href="https://github.com/GalaxiMaster/Exercise-App"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://play.google.com/store/apps/details?id=com.DylanJ.exercise_app">Google Play</a>
  </p>
</div>

<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>

## About The Project

Exercise App is designed for students and fitness enthusiasts who want a more data-driven way to track and improve their workouts and study sessions. Similar to apps like Hevy, it emphasizes metrics, consistency, and personalized tracking.

**Key Features:**

* Progress Tracking: Detailed statistics for workouts and study routines.
* Custom Routines: Users can create and manage their own workout plans.
* Interactive Dashboard: Visualize performance trends over time.
* State Management: Powered by Riverpod for smooth, reactive updates.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With

* [![Flutter][Flutter.dev]][Flutter-url]
* [![Dart][Dart.dev]][Dart-url]
* [![Riverpod][Riverpod.dev]][Riverpod-url]
* [![Firebase][Firebase.google.com]][Firebase-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Getting Started

### Prerequisites

* [Flutter SDK](https://docs.flutter.dev/install)

```bash
flutter doctor
```

### Installation

1. **Clone the repo**

```bash
git clone https://github.com/GalaxiMaster/Exercise-App
```

2. **Install Flutter packages**

```bash
flutter pub get
```

3. **Firebase Setup**

   * Create a Firebase project at [Firebase Console](https://console.firebase.google.com/).
   * Add an Android/iOS app to the project and download the `google-services.json` or `GoogleService-Info.plist`.
   * Place the files in `android/app/` and `ios/Runner/` respectively.

4. **Environment Variables**

   * Create a `.env` file in the root directory.
   * Add your Keys:

```env
ENCRYPTION_KEY=
serverClientId=
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Usage

The Exercise App allows users to track workouts and study sessions efficiently. The workflow includes:

1. Routine Creation: Users create customized workout plans.
2. Progress Monitoring: Track metrics and trends to identify improvements.
3. Data Insights: Analyze historical performance to optimize routines.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Roadmap

* [ ] Create a name and icon for the app
* [ ] Implement social/community sharing for progress and challenges

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## License

Distributed under the **MIT License**. See `LICENSE` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Contact

**Dylan J** - [dmj08bot@gmail.com](mailto:dmj08bot@gmail.com)
Project Link: [Exercise App GitHub](https://github.com/GalaxiMaster/Exercise-App)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

[Flutter.dev]: https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white
[Flutter-url]: https://flutter.dev
[Dart.dev]: https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white
[Dart-url]: https://dart.dev
[Firebase.google.com]: https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black
[Firebase-url]: https://firebase.google.com
[Riverpod.dev]: https://img.shields.io/badge/Riverpod-02569B?style=for-the-badge&logo=flutter&logoColor=white
[Riverpod-url]: https://riverpod.dev
