return {
  zh={
    appName="编译布局",
    title={
      prjPath="* 工程路径",
      alyPath="* ALY 布局路径",
      path="* PATH",
      _import="导入包（一行一个）",
    },
    hint={
      alyPath="相对路径位于工程根目录",
      path="路径间使用「;」隔开",
      _import="不导入任何包可能会导致连最基本的布局都无法编译的哦",
    },
    helper={
      path="注：生成 PATH 会覆盖原有内容。"
    },
    error={
      fileNotFound="文件不存在",
    },
    select="选择",
    generate="生成",
    sourceRepository="开源仓库",
    openSourceLicenses="开源许可证",
    exportHelper="导出 LayoutHelper",
    compileLayout="编译布局",
    messagePath="./i18n/zh/message.html"
  }
}