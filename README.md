# AndroLua+ Layout Compiler

[中文](README.zh.md) | **English**

Compile AndroLua+ layout, convert it into Lua code.

![Android 5.0+](https://img.shields.io/badge/Android-5.0%2B-green?logo=android)
![AndroLua+ 5.x](https://img.shields.io/badge/AndroLua%2B-5.x-blue?logo=lua&logoColor=blue)

## Example

### Source

``` lua
{
  LinearLayout,
  orientation="vertical",
  layout_width="fill",
  layout_height="fill",
  {
    TextView,
    gravity="center",
    text="Hello AndroLua+",
    layout_width="fill",
    layout_height="fill",
  },
}
```

### After compiling

```lua
local LayoutHelper=require "LayoutHelper"
return function(root,group)
  local varsMap={}
  root=root or _G
  varsMap.view0=LinearLayout(activity)
  varsMap.params0=ViewGroup.LayoutParams(-1,-1)
  varsMap.params0=group and group.LayoutParams(varsMap.params0) or ViewGroup.LayoutParams(varsMap.params0)
  varsMap.view1=TextView(activity)
  varsMap.params1=LinearLayout.LayoutParams(ViewGroup.LayoutParams(-1,-1))
  varsMap.view1.setText("Hello AndroLua+")
  varsMap.view1.setGravity(17)
  varsMap.view1.setLayoutParams(varsMap.params1)
  --varsMap.params1=nil
  varsMap.view0.addView(varsMap.view1)
  --varsMap.view1=nil
  varsMap.view0.setOrientation(1)
  varsMap.view0.setLayoutParams(varsMap.params0)
  --varsMap.params0=nil
  --varsMap=nil
  return varsMap.view0
end
```

## Software architecture

- Core documents
  - `lua/compilelayout.lua` Compiler ontology.
  - `lua/VituralG.lua` Virtual`_ G `, used to obtain code calls.
  - `lua/obj2code.lua` Tools for converting objects into code.
  - `LayoutHelper.lua` layout helper that needs to be imported within the target software to provide some classes.
- Other files
  - `lua/i18n/` [i18n.lua](https://github.com/kikito/i18n.lua) for lua.
  - `lua/themeutil.lua` Theme helper for adaptive target platforms. This is a must-have component for AideLua shared pages.
  - `main.lua` AndroLua+ entry file.
  - `init.lua` AndroLua+ configuration file.
  - `layout.aly` Software layout file.
  - `i18n/` Internationalization profile.

## Installation Tutorial

1. Go to the [Gitee Release (NOT GITHUB)](https://gitee.com/AideLua/AndroLuaLayoutCompiler/releases/latest) and download the pre-compiled installation package, usually with a filename ending in `.apk`.
2. Follow the tutorial in ["Flashing Guide - Install Software" (Chinese)](https://jesse205.github.io/FlashAndroidDevicesGuidelines/normal/installApk/) to install the utility.

## Instructions for use

1. Fill in the information in the edit box above.
2. Click "Export LayoutHelper" to export `LayoutHelper.lua` to the `Project/lua` directory (or `Project/Module/Type/src/luaLibs` for AideLua).
3. Click the "Compile Layout" button and select the save path.

## Participation in contributions

1. Fork this repository
2. Create a new branch for Feat_xxx
3. Commit code
4. Create a new Pull Request

The [Gitee](https://gitee.com/AideLua/AndroLuaLayoutCompiler) repository is primary, and the [GitHub](https://github.com/AideLua/AndroLuaLayoutCompiler) repository is mirrored.\
Although the repositories on GitHub are mirrors, you are not prevented from submitting Issues.

### Translation

1. Copy `i18n/en.lua` to `i18n/your-language.lua`
2. Copy `i18n/en/*` to `i18n/your-language/*`
3. Translate `i18n/your-language.lua` and `i18n/your-language/*`
4. Commit the code and create a new Pull Request

## Other Content

For additional information, please refer to the instructions in the software.
