# NamelessAI

NamelessAI 是一个功能丰富的 AI 聊天工具。

它基于Flutter，因此可以实现跨平台使用。

它支持用户添加自定义的 API 提供商，并在聊天界面自行选择模型。

它同时支持流式输出和非流式输出，并且可以自定义System Prompt并使用模板。

## 如何编译

1.  **克隆仓库**:
    ```bash
    git clone https://github.com/youshen2/NamelessAI.git
    cd NamelessAI
    ```

2.  **下载依赖**:
    ```bash
    flutter pub get
    ```

3.  **生成适配器和l10n**:
    ```bash
    flutter packages pub run build_runner build --delete-conflicting-outputs
    flutter gen-l10n
    ```

4.  **运行应用**:
    ```bash
    flutter run
    ```

## 使用说明

1.  **添加 API 提供商**:
    *   进入 "设置" -> "API 供应商设置"。
    *   点击右下角的 "+" 按钮添加新的提供商。
    *   填写提供商名称、基础 URL (例如：`https://api.openai.com`) 和 API Key。
    *   为该提供商添加模型，填写模型名称 (例如`GPT-3.5`）
    *   保存。

2.  **开始聊天**:
    *   回到 "聊天" 界面。
    *   在Chat Setting中选择你添加的 API 提供商和模型。
    *   在底部的输入框中输入你的消息并发送。

3.  **管理历史对话**:
    *   点击顶部的 "保存" 图标保存当前会话，并为其命名。
    *   如果不手动保存，会话也会自动存在历史记录当中。
    *   进入 "历史" 界面查看所有保存的对话。点击对话可加载并继续。

4.  **编辑/删除消息**:
    *   在聊天界面，将鼠标移动到气泡的位置，可以对气泡进行操作。
    *   选择 "编辑消息" 来修改消息内容。
    *   选择 "删除消息" 来移除消息。
    *   选择 "重新生成" 来重新尝试一次结果。

## 注意事项

*   本项目假定 API 提供商遵循 OpenAI 的 Chat Completions API 规范。如果你的提供商有不同的接口，可能需要修改 `lib/api/api_service.dart`。

## 贡献

欢迎通过 Pull Request 或 Issue 提交贡献和建议。
