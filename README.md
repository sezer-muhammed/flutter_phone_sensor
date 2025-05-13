# Flutter Phone Sensor Server: Turn Your Phone into a Data Source!

Ever wondered what your phone's sensors are up to? This Flutter app transforms your smartphone into a mini data server, letting you access its accelerometer, gyroscope, and magnetometer readings directly from your computer or any device on your local network!

Imagine:

-   Streaming your phone's motion data for a DIY motion controller.
-   Visualizing sensor data in real-time for a cool tech demo.
-   Learning about how mobile sensors work by seeing their output live.

This app makes it easy and fun!

## Cool Features

-   📱 **Access Core Sensors**: Get data from your phone's accelerometer (measures motion), gyroscope (measures rotation), and magnetometer (measures magnetic fields).
-   🚀 **Instant Data**: Sensor readings are grabbed the moment you ask for them via a simple web link – no constant draining of your battery!
-   🖥️ **Easy-to-See Info**: The app clearly shows:
    -   The IP address and port to connect to (like `192.168.1.10:8080`).
    -   Whether the server is up and running.
    -   When the last data request was made.
-   🌐 **Web Friendly**: Designed to work smoothly with web applications thanks to built-in CORS support.
-   뼈 **Flutter Powered**: Built with Flutter, so it's designed to be cross-platform (though sensor access can differ between Android and iOS).

## How It's Built (The Simple Version)

We've organized the app neatly so it's easy to understand and build upon:

-   **The App Itself (`lib/main.dart`, `lib/app.dart`)**: Kicks things off.
-   **What You See (`lib/presentation/`)**: The screens and buttons you interact with.
-   **The Brains (`lib/domain/`, `lib/data/`)**: Defines what sensor data looks like and how to fetch it.
-   **The Server Magic (`lib/server/`)**: Handles the web server that sends out the sensor data.
-   **Helpful Tools (`lib/utils/`)**: Little helpers, like figuring out your phone's IP address.

## Get It Running in Minutes!

### What You'll Need:

-   Flutter installed on your computer. If not, get it here: [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)
-   An Android or iOS phone (or an emulator, but real phones are more fun for sensors!).

### Let's Go:

1.  **Get the Code**: If you've cloned this repository, you're set. Otherwise, download the project files.
2.  **Open Your Terminal/Command Prompt** and go to the project folder:

    ```powershell
    cd path\to\flutter_phone_sensor
    ```

3.  **Install Dependencies** (the bits and pieces the app needs):

    ```powershell
    flutter pub get
    ```

4.  **Run the App!**

    ```powershell
    flutter run
    ```

    Flutter will build the app and install it on your connected phone or emulator. Look at the app screen!

### See Your Sensor Data!

Once the app is running:

1.  The app will show you an IP address and port, like `192.168.1.10:8080`.
2.  On another device (like your computer) connected to the *same Wi-Fi network*, open a web browser.
3.  Type in the address you saw, followed by `/api/get-imu`:

    `http://<YOUR_PHONE_IP>:8080/api/get-imu`

    (Replace `<YOUR_PHONE_IP>` with the actual IP from the app.)

4.  **Boom!** You should see a JSON response with the latest sensor readings:

    ```json
    {
        "accelerometer": [0.1, 9.8, 0.5],
        "gyroscope": [0.01, 0.02, 0.005],
        "magnetometer": [20.5, -15.2, 40.1],
        "timestamp": "2025-05-13T10:30:00.123Z"
    }
    ```

    If a sensor isn't available, its value will be `null`.

## Playing Around (For Developers)

### Testing the App

We have a basic test to make sure the app starts up. You can run it with:

```powershell
flutter test
```

## What's Next? (Ideas for a Rainy Day)

This app is a great starting point. Here are some cool things you could add:

-   **Nicer UI**: Make the app look even cooler, maybe with graphs of the sensor data.
-   **Settings**: Add a page to choose which sensors to use or how often to update.
-   **Live Streaming**: Use WebSockets to stream data to your computer in real-time without refreshing.
-   **More Data**: Include things like sensor accuracy or units.
-   **Better Logging**: For developers, add more detailed logs to see what's happening under the hood.

---

Have fun exploring your phone's sensors!
