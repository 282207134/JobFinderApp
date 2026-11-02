# Pixso 设计与实现对照

来源：Job Finder Figma → Page 1（0:1）。已读取此文件全部 30 张顶层画板；本文件没有其他页面分类。

相同页面的空白、填写、选择和页签状态由同一 Flutter 页面实现。以下两列分别是原始设计导出与模拟器运行截图。

| 序号 | Pixso 画板 | 节点 ID | 原始设计 | App 截图 |
| --- | --- | --- | --- | --- |
| 01 | Onboarding | 117:1152 | [设计](design/01-onboarding.png) | [运行截图](screenshots/01-onboarding-dream.png) |
| 02 | Onboarding | 117:1289 | [设计](design/02-onboarding.png) | [运行截图](screenshots/02-onboarding-application.png) |
| 03 | Onboarding | 117:1555 | [设计](design/03-onboarding.png) | [运行截图](screenshots/03-onboarding-career.png) |
| 04 | Login | 117:1959 | [设计](design/04-login.png) | [运行截图](screenshots/04-login-empty.png) |
| 05 | Login | 117:2109 | [设计](design/05-login.png) | [运行截图](screenshots/05-login-filled.png) |
| 06 | Signup | 117:1994 | [设计](design/06-signup.png) | [运行截图](screenshots/06-signup-empty.png) |
| 07 | Signup | 117:2038 | [设计](design/07-signup.png) | [运行截图](screenshots/07-signup-filled.png) |
| 08 | Forget Password | 117:2159 | [设计](design/08-forget-password.png) | [运行截图](screenshots/08-forgot-password.png) |
| 09 | OTP Verification | 117:2224 | [设计](design/09-otp-verification.png) | [运行截图](screenshots/09-otp-verification.png) |
| 10 | Reset Password | 117:2176 | [设计](design/10-reset-password.png) | [运行截图](screenshots/10-reset-password.png) |
| 11 | Phone Numbet | 117:2249 | [设计](design/11-phone-numbet.png) | [运行截图](screenshots/11-phone-number.png) |
| 12 | Home | 117:1068 | [设计](design/12-home.png) | [运行截图](screenshots/12-home.png) |
| 13 | Search | 117:826 | [设计](design/13-search.png) | [运行截图](screenshots/13-search-recent.png) |
| 14 | Search | 117:986 | [设计](design/14-search.png) | [运行截图](screenshots/14-search-results.png) |
| 15 | Catagory | 117:493 | [设计](design/15-catagory.png) | [运行截图](screenshots/15-categories.png) |
| 16 | Catagory | 117:645 | [设计](design/16-catagory.png) | [运行截图](screenshots/16-categories-all.png) |
| 17 | Popular Jobs | 117:912 | [设计](design/17-popular-jobs.png) | [运行截图](screenshots/17-popular-jobs.png) |
| 18 | Jobs | 117:351 | [设计](design/18-jobs.png) | [运行截图](screenshots/18-job-description.png) |
| 19 | Jobs | 117:391 | [设计](design/19-jobs.png) | [运行截图](screenshots/19-job-map.png) |
| 20 | Jobs | 117:441 | [设计](design/20-jobs.png) | [运行截图](screenshots/20-job-review.png) |
| 21 | Filter | 117:301 | [设计](design/21-filter.png) | [运行截图](screenshots/21-filter-empty.png) |
| 22 | Filter | 117:250 | [设计](design/22-filter.png) | [运行截图](screenshots/22-filter-filled.png) |
| 23 | Activity | 117:186 | [设计](design/23-activity.png) | [运行截图](screenshots/23-activity.png) |
| 24 | Profile | 117:124 | [设计](design/24-profile.png) | [运行截图](screenshots/24-profile.png) |
| 25 | Settings | 117:49 | [设计](design/25-settings.png) | [运行截图](screenshots/25-settings.png) |
| 26 | Payment Methods | 117:1811 | [设计](design/26-payment-methods.png) | [运行截图](screenshots/26-payment-methods.png) |
| 27 | Add Card | 117:1693 | [设计](design/27-add-card.png) | [运行截图](screenshots/27-add-card-empty.png) |
| 28 | Add Card | 117:1748 | [设计](design/28-add-card.png) | [运行截图](screenshots/28-add-card-filled.png) |
| 29 | Notification | 117:1896 | [设计](design/29-notification.png) | [运行截图](screenshots/29-notifications.png) |
| 30 | Map | 117:15 | [设计](design/30-map.png) | [运行截图](screenshots/30-map.png) |

## 实现说明

- 三张 Onboarding 画板合并为三步引导。
- Login、Signup、Filter、Add Card 的重复画板合并为空白/填写状态。
- Jobs 的三个画板实现为 Description、Map、Review 页签。
- Category 的两个画板通过 Show All 从四项切换为六项。
- 原稿 Map 底图为空白，因此保留路线示意；详情页使用原稿的静态地图素材。缩放和拖动仅作用于本地示意图。
- 根据可操作流程补充收藏、申请确认、资料编辑、申请记录、帮助、无结果与深色主题截图。
- 分类计数、收益日期和样例通知时间沿用设计语境，不代表当前实时数据。

节点清单：[frames.json](design/frames.json)；文字检查记录：[text-nodes.json](design/text-nodes.json)。
