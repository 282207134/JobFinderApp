# Android 安装包

| 文件 | 适用设备 |
| --- | --- |
| [job-finder-arm64-v8a.apk](job-finder-arm64-v8a.apk) | 大多数现代 Android 手机，约 20.1 MB |
| [job-finder-armeabi-v7a.apk](job-finder-armeabi-v7a.apk) | 较旧的 32 位 ARM Android 设备，约 17.6 MB |
| [job-finder-x86_64.apk](job-finder-x86_64.apk) | 当前 Android 模拟器，约 21.6 MB |

应用名称：Job Finder。包名：com.jobfinder.job_finder。版本：1.0.0（1）。

这些是正式优化模式编译、使用开发签名的本地验收包，不是应用商店发行包。登录、岗位与支付均为演示流程，不连接真实后端。

可直接复制到 Android 设备安装；如使用 adb：

~~~bash
adb install -r job-finder-arm64-v8a.apk
~~~

文件校验值见 [SHA256SUMS.txt](SHA256SUMS.txt)。
