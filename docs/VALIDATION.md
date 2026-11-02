# 验证记录

验收日期：2026-11-02。主要平台为 Android。

## 环境

| 项目 | 版本 / 配置 |
| --- | --- |
| Flutter / Dart | 3.47.7 stable / 3.13.5 |
| Android 模拟器 | Android 15，API 35，x86_64 |
| 截图分辨率 | 828 × 1792 像素，320 dpi，即 414 × 896 逻辑像素 |
| 小屏布局检查 | 320 × 640 |
| 字体与图片 | 本地 Poppins、原 Pixso 素材 |

## 检查结果

| 检查 | 结果 |
| --- | --- |
| flutter analyze | 无问题 |
| flutter test | 11 项通过：9 项数据/校验，2 项全页面布局 |
| Android 模拟器集成测试 | 完整操作流程通过 |
| 设计画板覆盖 | 30 / 30，见设计对照表 |
| App 截图 | 38 张，已生成截图总览及逐图索引 |
| Android release 构建 | arm64-v8a、armeabi-v7a、x86_64 三个包成功 |
| release 包安装启动 | x86_64 包安装成功，实际完成引导和登录，重启后恢复首页 |

### 数据与布局检查

关键词与组合筛选、评分排序、无结果、收藏增删与恢复、申请去重、主题和通知偏好恢复、搜索历史去重及数量上限、Remember me、退出登录、资料保存、银行卡末四位存储、邮箱/密码/Luhn/有效期校验均已检查。

所有路由均在 320×640 和 414×896 下挂载检查，未出现 RenderFlex 溢出。测试加载真实 Poppins 字体，避免默认测试字体造成尺寸误判。

### 模拟器实际操作

1. 三步引导进入登录；填写并勾选记住登录，进入首页。
2. 注册、确认密码、补充手机号并进入首页。
3. 找回密码、输入验证码、重置密码并返回登录。
4. 搜索 Business Management，组合选择类别、位置、时薪和 Part Time，确认结果变化。
5. 输入不存在的关键词，检查无结果提示。
6. 分类四项切换至六项，点击 Design 进入对应结果。
7. 详情页切换三个页签、收藏、确认申请，检查收藏和申请列表。
8. 通知详情标记已读，进入个人资料与设置。
9. 切换并恢复深色主题，关闭通知偏好，查看活动图表。
10. 选择支付方式，填写有效测试卡号并保存末四位。
11. 地图缩放与回到初始视图，查看帮助页。

### 截图方式

截图使用 Flutter 官方 integration_test 在 Android 模拟器中捕获实时渲染结果，由主机驱动保存 PNG。模拟器的软件渲染路径用于规避硬件渲染截图的局部缺失，不会替换页面内容或使用设计图作为页面背景。

docs/design 是原始 Pixso 导出，docs/screenshots 是实际 App 截图，两者明确分开。总览是从运行截图缩小排版生成，原始 PNG 保留完整分辨率。

## 可复现命令

~~~bash
flutter analyze
flutter test
flutter drive --driver=test_driver/screenshots.dart --target=integration_test/app_flow_test.dart -d emulator-5554 --enable-software-rendering --no-enable-impeller
python tools/build_gallery.py
flutter build apk --release --split-per-abi
~~~

模拟器截图测试使用独立的模拟存储，避免改变正常安装 App 的资料。实际运行使用设备本地存储；持久化恢复由单元测试验证。

## 验证边界

未验证真实招聘接口、认证、推送、邮件/短信、地图定位、导航或支付扣款，因为本项目未连接这些服务。iOS 需要 macOS/Xcode，本次没有构建与真机测试；Web 入口未作为主要验收平台。

Android 安装包用于本地演示验收，采用开发签名。正式发布需要替换签名、配置后端服务并补充对应平台的集成测试。

release 包使用设备原生输入完成登录，并通过重启检查 Remember me。原生屏幕截图：[release-home.png](release-home.png)。
