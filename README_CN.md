# Nameless AI Box

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

一个简洁、强大、跨平台的 AI 客户端，使用 Flutter 构建。它允许你连接到任何兼容 OpenAI 格式的 API 服务，包括你自己部署的本地模型服务。

## ✨ 功能特性

- **通用 API 支持**: 轻松连接到任何兼容 OpenAI API 规范的服务商，或通过高级设置自定义 API 路径。
- **多模型类型**: 不仅支持语言模型聊天，还集成了对**即时图像生成**、**异步图像生成 (Midjourney 代理)** 和**视频生成**的支持。
- **高度可定制**:
    - **界面**: 浅色/深色主题、莫奈取色 (Android 12+)、圆角大小、模糊效果、字体大小、气泡对齐方式等。
    - **聊天**: 自定义系统提示词 (System Prompt)、Temperature、Top P、上下文消息数量等。
    - **服务商**: 自由添加、编辑、删除 API 服务商及其下的模型。
- **数据管理**: 所有数据（配置、聊天记录）均存储在本地。支持一键导出和导入备份数据，方便迁移和共享。
- **跨平台**: 基于 Flutter 构建，理论上支持 Android, iOS, Windows, macOS, Linux。
- **本地优先**: 您的所有聊天记录、API密钥和设置都安全地存储在您的设备上。

## 📂 项目结构

项目遵循标准的 Flutter 项目结构，核心代码位于 `lib` 目录下：

```
lib
├── api/              # API 服务和数据模型 (请求/响应)
├── data/             # 本地数据管理
│   ├── models/       # Hive 数据库模型
│   └── providers/    # 状态管理 (Provider)
├── l10n/             # 国际化/本地化文件 (.arb)
├── router/           # 路由管理 (go_router)
├── screens/          # 应用的各个页面/屏幕
│   ├── chat/
│   ├── history/
│   ├── settings/
│   └── ...
├── services/         # 业务逻辑服务 (备份, 更新, 振动等)
├── utils/            # 辅助工具类 (主题, 帮助函数等)
├── widgets/          # 可复用的 UI 组件
└── main.dart         # 应用入口文件
```

## 🚀 编译与运行

### 环境准备

1.  确保你已经安装并配置好了 [Flutter SDK](https://flutter.dev/docs/get-started/install) (建议使用最新的稳定版)。
2.  安装你喜欢的 IDE，如 Visual Studio Code 或 Android Studio。

### 步骤

1.  **克隆仓库**
    ```bash
    git clone https://github.com/youshen2/NamelessAI.git
    ```

2.  **进入项目目录**
    ```bash
    cd NamelessAI
    ```

3.  **获取依赖**
    ```bash
    flutter pub get
    ```

4.  **运行应用 (调试模式)**
    ```bash
    flutter run
    ```

### 构建发行版

你可以为不同的平台构建发行版应用：

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

## 🤝 贡献代码、适配新接口

我们欢迎任何形式的贡献！

如果您希望应用支持某个特定的、非标准的 AI 服务商接口，请在 GitHub 上提交一个 **Issue**，并提供尽可能详细的接口信息。这将极大地帮助我们进行适配。

请在 Issue 中包含以下信息：

### 1. 语言模型

- **服务商名称**: [例如：My AI Service]
- **请求 URL**: [例如：https://api.my-ai.com/v1/chat]
- **请求方法**: [例如：POST]
- **请求头 (Headers)**:
  - Content-Type: application/json
  - Authorization: Bearer {API_KEY}
  - [其他必要的头信息]
- **请求体 (Request Body)**:
  ```json
  {
    "model": "{MODEL_NAME}",
    "messages": [
      {"role": "system", "content": "..."},
      {"role": "user", "content": "..."}
    ],
    "stream": true,
    // 其他参数...
  }
  ```
- **流式响应格式 (Streaming Response Format)**:
  ```
  data: {"id": "...", "choices": [{"delta": {"content": "Hello"}}]}

  data: {"id": "...", "choices": [{"delta": {"content": " world"}}]}

  data: [DONE]
  ```
- **非流式响应格式 (Non-streaming Response Format)**:
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

### 2. 图像生成模型

#### 即时生成

- **服务商名称**: [例如：My Image Service]
- **请求 URL**: [例如：https://api.my-image.com/v1/images]
- **请求方法**: [例如：POST]
- **请求头 (Headers)**: [...]
- **请求体 (Request Body)**:
  ```json
  {
    "prompt": "A cute cat",
    "model": "{MODEL_NAME}",
    "n": 1,
    "size": "1024x1024"
  }
  ```
- **成功响应格式 (Success Response Format)**:
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

#### 异步生成

- **服务商名称**: [例如：My Async Image Service]

- **任务提交接口**:
  - **URL**: [例如：https://api.my-async.com/submit]
  - **方法**: [例如：POST]
  - **请求体**: `{"prompt": "A cute cat"}`
  - **响应体**: `{"task_id": "xyz123"}`

- **任务查询接口**:
  - **URL**: [例如：https://api.my-async.com/query/{task_id}]
  - **方法**: [例如：GET]
  - **成功响应体 (包含图片URL)**:
    ```json
    {
      "status": "SUCCESS",
      "image_url": "https://.../image.png",
      "progress": "100%"
    }
    ```

### 3. 视频生成模型

- **服务商名称**: [例如：My Video Service]

- **任务创建接口**:
  - **URL**: [例如：https://api.my-video.com/v1/create]
  - **方法**: [例如：POST]
  - **请求体**: `{"prompt": "A running horse"}`
  - **响应体**: `{"task_id": "abc456", "status": "SUBMITTED"}`

- **任务查询接口**:
  - **URL**: [例如：https://api.my-video.com/v1/query?id={task_id}]
  - **方法**: [例如：GET]
  - **成功响应体 (包含视频URL)**:
    ```json
    {
      "status": "SUCCESS",
      "video_url": "https://.../video.mp4"
    }
    ```

## 📄 开源协议

本项目采用 **Apache License 2.0** 开源协议。

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