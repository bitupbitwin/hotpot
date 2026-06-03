# 🍲 火锅捞捞 (Hotpot Timer)

一个专为火锅爱好者设计的极简、直观的食材捞取时间管理工具（基于 Flutter 构建）。支持多种经典食材分类，采用呼吸闪烁的光圈状态机直观呈现食材的生熟程度，并配以轻触反馈、完美熟透及严重超时的分级硬件震动与声效提示，让你彻底告别“咬不动”与“煮化了”。

---

## 🌟 功能亮点 (Key Features)

- **⏱️ 预设黄金时间**：内置经典火锅食材的推荐煮制时间（如“七上八下”的毛肚15s、鲜切鸭肠12s、手工虾滑24s、潮汕牛肉丸10min等）。
- **⭕ 状态机呼吸光圈**：
  - **未下锅 (Idle)**：黑色外圈，点击即可下锅启动计时。
  - **煮熟中 (Counting)**：黄色光圈伴随中频呼吸闪烁，实时倒计时。
  - **完美熟透 (Ready)**：绿色光圈常亮并伴有舒缓呼吸动效。触发**完美叮咚音效**及**轻微震动**。
  - **严重超时 (Overcooked)**：超时超过60秒后，光圈变为红色并开始高频疯狂闪烁，每隔15秒循环进行**急促连续震动与声效催促**。
- **📳 硬件级震动声效联动**：使用 `vibration` 与 `HapticFeedback` 深度结合，提供下锅轻触反馈、熟透提醒和超时警报。
- **🛡️ 状态防抖保护**：在 Widget 树重构或列表发生变动时，内部通过 `didUpdateWidget` 拦截并重置计时器，防止不同食材的计时状态发生错乱。
- **🎨 极简黑金风 UI**：适配主流手机，全黑暗色主题背景，凸显多彩状态指示环。

---

## 📸 效果预览 (Preview)

![App Screenshot](./shot1.png)

---

## 🏗️ 目录结构 (Directory Structure)

```text
lib/
├── main.dart                      # 入口，锁定竖屏并初始化硬件反馈服务
├── data/
│   └── default_items.dart         # 食材静态预设数据 (毛肚/鸭肠/牛肉/虾滑/素菜等)
├── models/
│   └── hotpot_item.dart           # 食材数据模型与状态枚举 (HotpotState)
├── services/
│   └── feedback_service.dart      # 震动/声效/触觉反馈统一控制服务
├── widgets/
│   └── hotpot_item_widget.dart    # 计时状态机、动画渲染及外圈绘制核心组件
└── screens/
    └── home_screen.dart           # 2列网格卡片式主页面
```

---

## 🛠️ 构建与运行 (Build & Run)

### 前提条件 (Prerequisites)
- Flutter SDK (≥ 3.22.0)
- Android SDK / Xcode (iOS)

### 运行步骤 (Steps)

1. 克隆项目 (Clone the repository)：
   ```bash
   git clone https://github.com/bitupbitwin/hotpot.git
   cd hotpot
   ```

2. 获取依赖包 (Get dependencies)：
   ```bash
   flutter pub get
   ```

3. 运行调试 (Run in debug mode)：
   ```bash
   flutter run                 # 运行在已连接的手机/模拟器上
   ```

4. 打包 Android 调试包 (Build Android debug APK)：
   ```bash
   flutter build apk --debug
   ```

---

## 🔒 权限合规 (Permissions)
本应用在安卓端配置了震动权限：
* `android.permission.VIBRATE` 用于在食材煮熟和严重超时时发送震动警报，保证后台/熄屏状态下的提醒效果。
