# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

「日记」—— 一款本地优先的 Flutter 手账类日记 App，Material 3。**M2 已完成**：日记的本地持久化（drift/SQLite）与「新建 / 列表 / 详情 / 编辑 / 删除」闭环已打通；日历、搜索、设置三页仍为占位。代码注释全部为中文，新增代码请沿用中文注释。

## 环境与依赖（国内网络关键）

项目已脚手架化（平台 = windows + web，**主攻 Windows 桌面**；web 端 drift 需要 wasm 资源，尚未配置，暂不可用）。已就绪依赖：

- 运行时：`flutter_riverpod`、`go_router`、`drift` + `drift_flutter` + `path_provider`
- 代码生成（dev）：`drift_dev` + `build_runner`
- 后续按需：`table_calendar`（M3 日历）

Android 工具链尚未安装（缺 Android SDK）；将来做 Android 需装 Android Studio，并为 Gradle 配置 maven 国内镜像。

### Windows 构建关键（否则各种卡 / 报错）

- **必须开启开发者模式**：构建带原生插件的 app（`flutter run` / `flutter build`）要创建 symlink，否则报 `Building with plugins requires symlink support`。开启：管理员 PowerShell `reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /v AllowDevelopmentWithoutDevLicense /t REG_DWORD /d 1 /f`，或设置 → 开发者选项打开开关。（`flutter test` 不需要。）
- **中文用户名路径要用英文 TEMP**：用户目录是 `C:\Users\杨娇`，Dart AOT / build_runner 在含中文的临时路径下会报 `Unable to read file: ...program.dill`。所有会 AOT 编译的命令（build_runner、flutter test、flutter build/run）加前缀 `TMP='D:\tmp\dartbuild' TEMP='D:\tmp\dartbuild'`。
- 更多细节见记忆 `flutter-windows-build-gotchas`。

### 国内网络必须用镜像（否则 pub get 卡死）

默认 pub.dev 的包体存放在被墙的 Google 云存储，直连会卡在 `Downloading packages...`。**腾讯/清华是"假镜像"**：只代理元数据 API，包体地址（archive_url）仍指向 pub.dev。**实测唯一可用的是 `flutter-io.cn`**。镜像变量已 `setx` 持久化到用户环境（新开终端自动生效）；若某终端没生效，显式加前缀：

```bash
PUB_HOSTED_URL=https://pub.flutter-io.cn FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn flutter pub get
```

切换镜像后若仍卡，删掉 `pubspec.lock` 再 get —— 旧 lock 会把包源锁回 pub.dev。

## 常用命令

```bash
flutter analyze   # 或 dart analyze（纯静态，绕开插件 symlink）
dart format lib/
flutter test                      # 全部测试（带下方 TEMP 前缀）
flutter test test/foo_test.dart   # 单个文件
flutter run -d windows            # Windows 桌面运行（需开发者模式）

# 改了 drift 表/数据库定义后，重新生成 *.g.dart
TMP='D:\tmp\dartbuild' TEMP='D:\tmp\dartbuild' dart run build_runner build
```

> 联网命令（pub get / build_runner / run / test）若所在终端未继承镜像变量，再补 `PUB_HOSTED_URL` / `FLUTTER_STORAGE_BASE_URL` 前缀。

## 架构

**按功能分层（feature-first）**，入口 `main.dart` → `ProviderScope`（Riverpod 全局状态）→ `app.dart`（`MaterialApp.router`）。

- `lib/core/` —— 跨功能共享层
  - `theme/`：`app_colors.dart`（**全局调色板**）+ `app_theme.dart`（M3 主题，`radius=16`）
  - `router/app_router.dart`：`go_router` 路由表。`/`→`HomeShell`；`/entry/new`（新建）、`/entry/:id`（详情）、`/entry/:id/edit`（编辑）为顶层 push，盖在外壳之上。**`/entry/new` 必须排在 `/entry/:id` 前**。
  - `widgets/`：`PaperCard`、`EmptyState`
  - `database/`：`app_database.dart`（drift 表 `Entries` + `AppDatabase`）+ 生成的 `app_database.g.dart`。数据库是跨 feature 基础设施，M3 日历/搜索复用同库。
- `lib/features/<feature>/` —— 业务功能。`diary` 已是完整四层范例：
  - `domain/`：`mood.dart`（`Mood` 枚举）
  - `data/`：`diary_repository.dart`（封装 drift 的 CRUD，`watch*` 返回响应式流）
  - `application/`：`diary_providers.dart`（`appDatabaseProvider` / `diaryRepositoryProvider` / `diaryListProvider` / `diaryEntryProvider`）
  - `presentation/pages/`：列表 / 详情 / 编辑三页；`presentation/widgets/`：`MoodPicker`、`DiaryEntryCard`
- `features/home/home_shell.dart`：底部导航外壳，`IndexedStack` **保活**四页。

**数据流**：UI `ref.watch(diaryListProvider)`（StreamProvider 接 drift `watch`）渲染列表；写操作 `ref.read(diaryRepositoryProvider).create/update/delete(...)`，drift 自动把新结果推回流、列表实时刷新 —— 不手写状态管理。

## 设计系统

视觉基调：**暖米色纸感手账** —— 米白底 + 墨色字 + 单一莫兰迪鼠尾草绿强调色。原则：低投影、圆角（`AppTheme.radius = 16`）、充足留白。

- **所有颜色必须经 `AppColors` 定义**，不要在组件里写死颜色值 —— 便于日后用 theme-factory 整体换肤。
- 主题以 `ColorScheme.fromSeed(强调色)` 生成，再覆盖纸感关键色。
- 字体：`AppTheme.fontFamily` 现为 `null`，打包 Noto Sans SC 后改为 `'NotoSansSC'`。

## 关键约定与约束

- **`Mood.id` 是持久化稳定字符串**（`features/diary/domain/mood.dart`），存库用。**切勿修改已有枚举的 `id`**，否则破坏历史数据；`Mood.fromId` 负责从存库值还原。
- **drift 生成物 `*.g.dart` 勿手改**；改了表/数据库定义必须重跑 `build_runner`（带英文 TEMP 前缀），否则 analyze 报 `_$AppDatabase` 未定义。数据库 `schemaVersion=1`，改表结构（如 M3 加 FTS5）需写 drift migration。
- **测试**：单元测试用 `AppDatabase(NativeDatabase.memory())` 内存库（drift 2.34 + sqlite3 3.x 经 build hooks 自动提供 sqlite3，`flutter test` 无需手装 dll）；widget 冒烟测试 override `diaryListProvider` 为替身，避免依赖真实 drift 与其 stream 在 dispose 时的 Timer 摩擦。
- **Flutter 版本适配**：若编译报错，按 `app_theme.dart` 顶部注释处理：`WidgetStateProperty`→`MaterialStateProperty`、`withValues(alpha:)`→`withOpacity()`。
- **本地化 TODO**：`app.dart` 尚未配置中文 `localizationsDelegates` / `supportedLocales`。

## 里程碑路线图

- **M2** ✅ 已完成：drift 数据层 + 日记新建/列表/详情/编辑/删除闭环 + 三条 `/entry` 路由。
- **M3**：`table_calendar` 月视图（日历页）；全文搜索 FTS5 trigram + LIKE 兜底（搜索页）。
- **M5/M6**：设置页接入主题、每日提醒、隐私锁等真实开关。
