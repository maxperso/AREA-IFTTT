# Project AREA - Action REAction

## Overview

Project AREA is a comprehensive software suite designed to function similarly to popular automation platforms like IFTTT and Zapier. It is divided into three main components:

1. **Application Server**: Implements the core features of the project (see Features section).
2. **Web Client**: A browser-based interface to interact with the application server.
3. **Mobile Client**: A mobile application for convenient access and interaction with the application server.

## Screenshots
<img width="1312" alt="1" src="https://github.com/maxperso/AREA-IFTTT/assets/91894666/6b4918a3-6d04-43d7-a793-aa9849fdd99e">
<img width="1462" alt="2" src="https://github.com/maxperso/AREA-IFTTT/assets/91894666/504d22fc-243a-4d5a-bb38-b63f7adc4739">
<img width="1462" alt="3" src="https://github.com/maxperso/AREA-IFTTT/assets/91894666/a66710c1-04e4-43bb-bf15-69f5a33220dc">

## Getting Started

Follow these steps to get the project up and running on your local machine.

1. Clone the repository: `git@github.com:EpitechPromo2026/B-DEV-500-LYN-5-2-area-virgile1.arnoux.git`
2. Navigate to the project directory: `cd B-DEV-500-LYN-5-2-area-virgile1.arnoux.git`
3. Run the following command to build the project: `docker-compose build`

Or if you want to launch manually you need to:

**app/backend**
```bash
node index.js
```

**app/frontend**
```bash
flutter run
```

### Usage

1. Start the application: `docker-compose up`
2. Access the web client in your browser at [http://localhost:8081].
3. Access the mobile client on your phone by connecting to the application server.
