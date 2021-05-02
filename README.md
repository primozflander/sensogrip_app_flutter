# SensoGrip App

Android and IOS companion App for Sensogrip pencil.

**Table of Contents**

- [SensoGrip](#sensogrip)
  * [About The Project](#about-the-project)
    + [Built With](#built-with)
  * [Getting Started](#getting-started)
    + [Prerequisites](#prerequisites)
    + [Installation via Visual Studio Code](#installation-via-visual-studio-code)
  * [Usage](#usage)
  * [License](#license)
  * [Contact](#contact)
  * [Acknowledgements](#acknowledgements)

<!-- ABOUT THE PROJECT -->
## About The Project

Sensogrip pencil was developed as a therapeutical help tool for children with graphomotoric difficulties. It consists of two sensors: one for measuring tip pressure, and the second one for measuring finger pressure. User is able to get feedback via built-in RGB led or via mobile app.

It features:
* Piezoelectric sensor for measuring tip pressure
* FSR sensor for measuring finger pressure
* Optical RGB led feedback (for example: green color lights up when the pressure on the sensors is right)
* Automatic measured pressure correction with angle from build-in IMU
* Sleep funtion with wake-up by shaking
* Bluetooth BLE connectivity
* Rechargable battery, which provides up to 10 hour of operating time
* Mobile App companion

### Built With

* [Flutter](https://flutter.dev)
* [Visual Studio Code](https://code.visualstudio.com)



<!-- GETTING STARTED -->
## Getting Started

Follow this steps to upload the App to your Android tablet.

### Prerequisites

* Android Studio
* Flutter
* Optional: Visual Studio Code


### Installation via Visual Studio Code

From the command line:

1. Enter `cd <your app dir>`
2. Run `flutter build apk --no-shrink`
3. Run `flutter install`


<!-- USAGE EXAMPLES -->
## Documentation

_For documentation, please refer to the [Documentation](/documentation)_



<!-- LICENSE -->
## License

Distributed under the FH Campus Wien License. See `LICENSE` for more information.



<!-- CONTACT -->
## Contact

Primoz Flander: primoz.flander@fh-campuswien.ac.at

Project Link: [SensoGrip](https://github.com/primozflander/senso-grip)



<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements
* [Gernot Korak](https://www.fh-campuswien.ac.at/forschung/forschende-von-a-z/personendetails/gernot-korak.html)
* [Sebastian Geyer](https://www.fh-campuswien.ac.at/forschung/forschende-von-a-z/personendetails/sebastian-geyer.html)
