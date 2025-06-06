# flutter-graphql

An app that uses the GitHub GraphQL APIs

### Prerequisites

- FVM (https://fvm.app/)
- Flutter SDK (version 3.32.1 or higher)
- A configured IDE (like VS Code or Android Studio) or the command line.

### Hiccup

- The app runs on web, but is not functional because the login mechanism isn't complete

### Steps

1.  Clone or download the project repository.
2.  Create a file `app.env.map.json` within the root of the project.

    The file should contain a json with the following structure:

    ```json
    {
      "clientId": "<your github client id>",
      "clientSecret": "<your github client secret>"
    }
    ```

    To obtain these values, follow the following steps:
    1. Log into GitHub
    2. Click your profile picture (top right) > Settings
    4. Scroll down and click Developer settings in the left sidebar
    5. Create a New OAuth App
        - In Developer settings, click OAuth Apps
        - Click the "New OAuth App" button
        - Fill in the Application Details
            - Application Name: A name for your app (e.g., "MyCoolApp")
            - Homepage URL: Your app’s main website (e.g., https://example.com)
            - Authorization Callback URL: Where GitHub will redirect users after login (e.g., https://example.com/callback)
    6. Register Application.
        
        Once registered, you'll see:
        - Client ID (visible immediately)
        - Client Secret (click "Generate a new client secret" to reveal it)

3.  Open the project in your terminal or IDE.
4.  Install the correct Flutter version
    ```
    fvm install
    ```
5.  Install dependencies by running:
    ```
    fvm flutter pub get
    ```
6.  Run the application on a connected device or emulator:
    ```
    fvm flutter run
    ```
