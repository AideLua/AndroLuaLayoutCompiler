# AndroLua+布局编译器

**中文** | [English](README.md)

编译 AndroLua+ 布局，转换为 Lua 代码。

![Android 5.0+](https://img.shields.io/badge/Android-5.0%2B-green?logo=android)
![AndroLua+ 5.x](https://img.shields.io/badge/AndroLua%2B-5.x-blue?logo=lua&logoColor=blue)

## 软件架构

- 核心文件
  - `lua/compilelayout.lua` 编译器本体
  - `lua/VituralG.lua` 虚拟 `_G`，用于获取代码调用。
  - `lua/obj2code.lua` 将对象转换为代码的工具
- 其他文件
  - `main.lua` AndroLua+ 入口文件
  - `init.lua` AndroLua+ 配置文件
  - `layout.aly` 软件布局文件

## 安装教程

1. 进入 [Gitee 发行版](https://gitee.com/AideLua/AndroLuaLayoutCompiler/releases/latest)下载预编译的安装包，文件名通常以 `.apk` 结尾
2. 按照[《刷机指南 - 安装软件》](https://jesse205.github.io/FlashAndroidDevicesGuidelines/normal/installApk/)的教程安装本工具软件

## 使用说明

1. 填入信息到上面的编辑框内
2. 点击“导出 LayoutHelper”，将 `LayoutHelper.lua` 导出到 `项目/lua` 目录内（AideLua为 `项目/模块/类型/src/luaLibs`）。
3. 点击“编译布局”按钮，选择保存路径。

## 参与贡献

1. Fork 本仓库
2. 新建 Feat_xxx 分支
3. 提交代码
4. 新建 Pull Request

[Gitee](https://gitee.com/AideLua/AndroLuaLayoutCompiler) 仓库为主，[GitHub](https://github.com/AideLua/AndroLuaLayoutCompiler) 仓库为镜像。\
虽然在 GitHub 上的仓库为镜像，但也不妨碍您提交 Issue。

### 翻译

1. 复制 `i18n/en.lua` 到 `i18n/你的语言.lua`
2. 复制 `i18n/en/*` 到 `i18n/你的语言/*`
3. 翻译 `i18n/你的语言.lua` 和 `i18n/你的语言/*`
4. 提交代码并新建 Pull Request

## 其他内容

其他内容请见软件内使用说明。
