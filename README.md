# Nameless AI Box

[中文README](./README_CN.md)

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

A simple, powerful, and cross-platform AI client built with Flutter. It allows you to connect to any API service compatible with the OpenAI format, including your own locally deployed model services.

## ✨ Features

- **Universal API Support**: Easily connect to any provider compatible with the OpenAI API specification, or customize API paths through advanced settings.
- **Multiple Model Types**: Supports not only language model chats but also integrates support for **real-time image generation**, **asynchronous image generation (Midjourney proxy)**, and **video generation**.
- **Highly Customizable**:
    - **UI**: Light/dark themes, Monet color theming (Android 12+), corner radius, blur effects, font size, bubble alignment, etc.
    - **Chat**: Customize system prompts, temperature, top_p, context message count, etc.
    - **Providers**: Freely add, edit, and delete API providers and their associated models.
- **Data Management**: All data (configurations, chat history) is stored locally. Supports one-click export and import of backup data for easy migration and sharing.
- **Cross-Platform**: Built with Flutter, theoretically supporting Android, iOS, Windows, macOS, and Linux.
- **Local-First**: All your chat history, API keys, and settings are securely stored on your device.

## 📂 Project Structure

The project follows a standard Flutter project structure, with the core code located in the `lib` directory:

```
lib
├── api/              # API services and data models (request/response)
├── data/             # Local data management
│   ├── models/       # Hive database models
│   └── providers/    # State management (Provider)
├── l10n/             # Internationalization/localization files (.arb)
├── router/           # Route management (go_router)
├── screens/          # Application pages/screens
│   ├── chat/
│   ├── history/
│   ├── settings/
│   └── ...
├── services/         # Business logic services (backup, update, vibration, etc.)
├── utils/            # Utility classes (theming, helper functions, etc.)
├── widgets/          # Reusable UI components
└── main.dart         # Application entry point
```

## 🚀 Build and Run

### Prerequisites

1.  Ensure you have the [Flutter SDK](https://flutter.dev/docs/get-started/install) installed and configured (the latest stable version is recommended).
2.  Install your preferred IDE, such as Visual Studio Code or Android Studio.

### Steps

1.  **Clone the repository**
    ```bash
    git clone https://github.com/youshen2/NamelessAI.git
    ```

2.  **Navigate to the project directory**
    ```bash
    cd NamelessAI
    ```

3.  **Get dependencies**
    ```bash
    flutter pub get
    ```

4.  **Run the app (debug mode)**
    ```bash
    flutter run
    ```

### Build for Release

You can build release versions for different platforms:

- **Android**:
  ```bash
  flutter build apk --release
  ```
- **iOS**:
  ```bash
  flutter build ipa --release
  ```
- **Windows**:
  ```bash
  flutter build windows --release
  ```
- **macOS**:
  ```bash
  flutter build macos --release
  ```
- **Linux**:
  ```bash
  flutter build linux --release
  ```

## 🤝 Contributing & Adapting New APIs

We welcome any form of contribution!

If you want the app to support a specific, non-standard AI provider API, please submit an **Issue** on GitHub with as much detail as possible. This will greatly help us with the adaptation.

Please include the following information in your Issue:

### 1. Language Models

```
- **Provider Name**: [e.g., My AI Service]
- **Request URL**: [e.g., https://api.my-ai.com/v1/chat]
- **Request Method**: [e.g., POST]
- **Request Headers**:
  - Content-Type: application/json
  - Authorization: Bearer {API_KEY}
  - [Other necessary headers]
- **Request Body**:
  ```json
  {
    "model": "{MODEL_NAME}",
    "messages": [
      {"role": "system", "content": "..."},
      {"role": "user", "content": "..."}
    ],
    "stream": true,
    // Other parameters...
  }
  ```
- **Streaming Response Format**:
  ```
  data: {"id": "...", "choices": [{"delta": {"content": "Hello"}}]}

  data: {"id": "...", "choices": [{"delta": {"content": " world"}}]}

  data: [DONE]
  ```
- **Non-streaming Response Format**:
  ```json
  {
    "id": "...",
    "choices": [
      {
        "message": {
          "role": "assistant",
          "content": "Hello world"
        }
      }
    ],
    "usage": {
      "prompt_tokens": 10,
      "completion_tokens": 2
    }
  }
  ```
```

### 2. Image Generation Models

#### Real-time Generation

```
- **Provider Name**: [e.g., My Image Service]
- **Request URL**: [e.g., https://api.my-image.com/v1/images]
- **Request Method**: [e.g., POST]
- **Request Headers**: [...]
- **Request Body**:
  ```json
  {
    "prompt": "A cute cat",
    "model": "{MODEL_NAME}",
    "n": 1,
    "size": "1024x1024"
  }
  ```
- **Success Response Format**:
  ```json
  {
    "created": 1677649963,
    "data": [
      {
        "url": "https://.../image.png"
      }
    ]
  }
  ```
```

#### Asynchronous Generation

```
- **Provider Name**: [e.g., My Async Image Service]

- **Task Submission Endpoint**:
  - **URL**: [e.g., https://api.my-async.com/submit]
  - **Method**: [e.g., POST]
  - **Request Body**: `{"prompt": "A cute cat"}`
  - **Response Body**: `{"task_id": "xyz123"}`

- **Task Query Endpoint**:
  - **URL**: [e.g., https://api.my-async.com/query/{task_id}]
  - **Method**: [e.g., GET]
  - **Success Response Body (containing the image URL)**:
    ```json
    {
      "status": "SUCCESS",
      "image_url": "https://.../image.png",
      "progress": "100%"
    }
    ```
```

### 3. Video Generation Models

```
- **Provider Name**: [e.g., My Video Service]

- **Task Creation Endpoint**:
  - **URL**: [e.g., https://api.my-video.com/v1/create]
  - **Method**: [e.g., POST]
  - **Request Body**: `{"prompt": "A running horse"}`
  - **Response Body**: `{"task_id": "abc456", "status": "SUBMITTED"}`

- **Task Query Endpoint**:
  - **URL**: [e.g., https://api.my-video.com/v1/query?id={task_id}]
  - **Method**: [e.g., GET]
  - **Success Response Body (containing the video URL)**:
    ```json
    {
      "status": "SUCCESS",
      "video_url": "https://.../video.mp4"
    }
    ```
```

## 📄 License

This project is licensed under the **Apache License 2.0**.

```
Copyright 2025 爅峫

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```