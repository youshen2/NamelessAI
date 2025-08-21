# NamelessAI

[中文README](README_CN.md)

NamelessAI is a feature-rich AI chat tool.

Built with Flutter, it offers cross-platform support.

It allows users to add custom API providers and select different models within the chat interface.

It supports both streaming and non-streaming responses, and allows for customizable System Prompts with templates.

## How to Compile

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/youshen2/NamelessAI.git
    cd NamelessAI
    ```

2.  **Get dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Generate adapters and l10n**:
    ```bash
    flutter packages pub run build_runner build --delete-conflicting-outputs
    flutter gen-l10n
    ```

4.  **Run the app**:
    ```bash
    flutter run
    ```

## Usage

1.  **Add an API Provider**:
    *   Go to "Settings" -> "API Provider Settings".
    *   Click the "+" button in the bottom-right corner to add a new provider.
    *   Fill in the Provider Name, Base URL (e.g., `https://api.openai.com`), and API Key.
    *   Add models for this provider by entering the model name (e.g., `GPT-3.5`).
    *   Save.

2.  **Start a Chat**:
    *   Return to the "Chat" screen.
    *   In the Chat Settings, select the API provider and model you added.
    *   Type your message in the input box at the bottom and send it.

3.  **Manage Chat History**:
    *   Click the "Save" icon at the top to save the current session and give it a name.
    *   Even if you don't save it manually, the conversation is automatically added to the history.
    *   Go to the "History" screen to view all saved conversations. Click on a conversation to load and continue it.

4.  **Edit/Delete Messages**:
    *   In the chat interface, hover your mouse over a message bubble to see the options.
    *   Select "Edit Message" to modify its content.
    *   Select "Delete Message" to remove it.
    *   Select "Regenerate" to get a new response.

## Notes

*   This project assumes that the API provider follows the OpenAI Chat Completions API specification. If your provider uses a different API structure, you may need to modify `lib/api/api_service.dart`.

## Contributing

Contributions and suggestions are welcome via Pull Requests or Issues.