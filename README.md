# SensoGrip App

Android companion App for Sensogrip pencil.

**Table of Contents**

- [SensoGrip](#sensogrip)
  * [About The Project](#about-the-project)
    + [Built With](#built-with)
  * [Getting Started](#getting-started)
    + [Prerequisites](#prerequisites)
    + [App installation](#app-installation)
    + [Software versions at the time of build](#software-versions-at-the-time-of-build)
  * [License](#license)
  * [Contact](#contact)
  * [Acknowledgements](#acknowledgements)

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



## Getting Started

Follow this steps to upload the App to your Android tablet.

### Prerequisites

* Android Studio
* Flutter
* Optional: Visual Studio Code


### App installation

1. Connect your android device to your PC
2. Open command line and move to the project folder `cd <your app dir>`
3. Run `flutter build apk --release`
4. Run `flutter install`


### Software versions at the time of build

* Flutter (2.4.0-0.0.pre)
* Dart (2.14.0)
* Visual Studio Code (1.59.0)

## License

Distributed under the FH Campus Wien License.

## Contact

Primoz Flander: [primoz.flanderfh-campuswien.ac.at](<mailto:user@example.com>)

Project Link: [SensoGrip App](https://github.com/primozflander/sensogrip_app_flutter), [SensoGrip Firmware](https://github.com/primozflander/sensogrip_pio)

## Acknowledgements
* [Gernot Korak](https://www.fh-campuswien.ac.at/forschung/forschende-von-a-z/personendetails/gernot-korak.html)
* [Sebastian Geyer](https://www.fh-campuswien.ac.at/forschung/forschende-von-a-z/personendetails/sebastian-geyer.html)
