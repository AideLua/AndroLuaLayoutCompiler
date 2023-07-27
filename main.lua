require "import"
import "android.app.*"
import "android.os.*"
import "android.widget.*"
import "android.view.*"
import "android.provider.DocumentsContract"
import "java.io.File"
import "android.net.Uri"
import "android.content.Intent"
import "java.io.FileInputStream"
import "java.io.FileOutputStream"
import "android.content.Context"
import "android.text.Html"

import "utils.DialogHelper"
import "utils.FileUtil"
import "utils.FileUriUtil"
import "themeutil"
import "helper"
import "compilelayout"
import "init"
import "LayoutHelper"

EXPORT_HELPER=1
PICK_ALY=2
SELECT_OUTPUT=3
PICK_PRJ=3
TYPES_LUA=String({"application/octet-stream","application/lua","text/plain"})

EXTRA_PRJ_PATH="prjPath"
EXTRA_FILE_PATH="filePath"

--禁用华为主题
--androidhwext=nil
--themeutil.isEmuiSystem=false
themeutil.applyTheme()

isAideLua=apptype=="aidelua"

--获取主题资源
local array = activity.obtainStyledAttributes({
  android.R.attr.colorAccent,
  android.R.attr.textColorPrimary,
  android.R.attr.textColorSecondary,
})
colorAccent=array.getColorStateList(0)
textColorPrimary=array.getColorStateList(1)
textColorSecondary=array.getColorStateList(2)

initPrjPath,initFilePath=...

local intent=activity.getIntent()
--初始工程路径与文件路径
initPrjPath=intent.getStringExtra(EXTRA_FILE_PATH) or initPrjPath
initFilePath=intent.getStringExtra(EXTRA_FILE_PATH) or initFilePath

initPrjPath=initPrjPath or "/storage/emulated/0/AppProjects/AideLuaPro"
initFilePath=initFilePath or "/storage/emulated/0/AppProjects/AideLuaPro/app/src/main/assets_bin/layouts/buildingLayout.aly"
parentFilePath=initFilePath and FileUtil.getParent(initFilePath) or initPrjPath

initShortPath=initFilePath and shortPath(initFilePath,initPrjPath)
--initOutputPath=initShortPath and initShortPath:gsub("%.aly$",".lua")
initEnvironmentPath=buildEnvPath(parentFilePath)

actionBar.setDisplayHomeAsUpEnabled(true)
actionBar.setSubtitle(string.format("v%s (%s)",appver,appcode))
activity.setContentView(loadlayout("layout"))

activity.getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_STATE_HIDDEN)

--修复点击后自动滚动问题
if Build.VERSION.SDK_INT>=25 then
  messageView.setRevealOnFocusHint(false)
end

messageView.setText(Html.fromHtml(decodeTemplateCode(readFile(luajava.luadir.."/message.html"))))

function onOptionsItemSelected(item)
  local id=item.getItemId()
  local title=item.title
  if id==android.R.id.home then
    activity.finish()
  end
end

---获取工程路径
function getPrjPath()
  return prjPathEdit.text
end

---获取ALY路径
function getAlyPath()
  return rel2AbsPath(alyPathEdit.text,getPrjPath())
end

function updateProjectPath(newPrjPath)
  local alyPath=getAlyPath()
  prjPathEdit.text=newPrjPath
  updateAlpPath(alyPath)
end

function updateAlpPath(newAlpPath)
  alyPathEdit.text=shortPath(newAlpPath,getPrjPath())
end

function compileFunc(importText,envPath,prjPath,alyPath)
  return pcall(function()
    require "import"
    import "android.net.Uri"
    import "android.os.Environment"
    import "java.io.FileInputStream"
    import "java.io.FileOutputStream"
    for line in (importText.."\n"):gmatch("(.-)\n") do
      if line~="" then
        _G["import"](line)
      end
    end
    import "compilelayout"
    local filePath

    if not alyPath:find("^/") then--相对路径
      filePath=prjPath.."/"..alyPath
    end
    return compilelayout(filePath,envPath)
  end)
end

function compileCallback(success,content)
  local dialog
  local builder=AlertDialog.Builder(this)
  if success then
    local editor=LuaEditor(activity)
    editor.text=content
    builder.setTitle("编译成功")
    .setView(editor)
    .setPositiveButton(android.R.string.ok,nil)
    dialog=builder.show()
    editor.format()
    editor.setScrollIndicators( View.SCROLL_INDICATOR_TOP | View.SCROLL_INDICATOR_BOTTOM,
    View.SCROLL_INDICATOR_TOP | View.SCROLL_INDICATOR_BOTTOM)
   else
    builder.setTitle("编译错误")
    .setMessage(content)
    .setPositiveButton(android.R.string.ok,nil)
    dialog=builder.show()
  end
  DialogHelper.setMessageIsSelectable(dialog,true)
end

exportHelperButton.onClick=function()
  local intent = Intent(Intent.ACTION_CREATE_DOCUMENT)
  intent.addCategory(Intent.CATEGORY_OPENABLE)
  intent.setType("application/octet-stream")
  intent.putExtra(Intent.EXTRA_MIME_TYPES,TYPES_LUA)
  intent.putExtra(Intent.EXTRA_TITLE, "LayoutHelper.lua")
  local prjPath=prjPathEdit.text
  local parentFilePath=FileUtil.getParent(getAlyPath())
  if parentFilePath~="" and parentFilePath:sub(1,#sdcardPath)==sdcardPath then
    intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, FileUriUtil.path2DocumentUri(parentFilePath,false))
   elseif prjPath and prjPath:sub(1,#sdcardPath)==sdcardPath then
    intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, FileUriUtil.path2DocumentUri(prjPath,false))
  end
  activity.startActivityForResult(intent,EXPORT_HELPER)
end


compileButton.onClick=function()
  activity.newTask(compileFunc,compileCallback)
  .execute({importEdit.text, pathEdit.text, prjPathEdit.text, alyPathEdit.text})
end

alyPathSelectButton.onClick=function()
  local intent = Intent(Intent.ACTION_GET_CONTENT)
  intent.addCategory(Intent.CATEGORY_OPENABLE)
  intent.setType("application/octet-stream")
  intent.putExtra(Intent.EXTRA_MIME_TYPES,TYPES_LUA)
  local parentFilePath=FileUtil.getParent(getAlyPath())

  if parentFilePath and parentFilePath:sub(1,#sdcardPath)==sdcardPath then
    intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, FileUriUtil.path2DocumentUri(parentFilePath,false))
    --[[
   elseif prjPath and String(prjPath).startsWith(sdcardPath) then--工程目录在SD卡目录下
    intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, path2DocumentUri(isAideLua and prjPath.."/app/src/main/assets_bin" or prjPath))]]
  end
  activity.startActivityForResult(intent,PICK_ALY)
end

prjPathSelectButton.onClick=function()
  local intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE)
  local previousPrjPath=prjPathEdit.text
  if previousPrjPath and String(previousPrjPath).startsWith(sdcardPath) then
    intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, FileUriUtil.path2DocumentUri(previousPrjPath,false))
  end
  activity.startActivityForResult(intent,PICK_PRJ)
end

generatePathButton.onClick=function()
  pathEdit.text=buildEnvPath(FileUtil.getParent(getAlyPath())) or ""
end
--[[
outputPathSelectButton.onClick=function()
  local intent = Intent(Intent.ACTION_CREATE_DOCUMENT)
  intent.addCategory(Intent.CATEGORY_OPENABLE)
  intent.setType("application/octet-stream")
  intent.putExtra(Intent.EXTRA_MIME_TYPES,TYPES_LUA)
  local name=getFileNameWithoutExtensionName(alyPathEdit.text)
  if name=="" then
    name="layout"
  end
  intent.putExtra(Intent.EXTRA_TITLE, name..".lua");
  activity.startActivityForResult(intent,SELECT_OUTPUT)
end]]

function onActivityResult(requestCode,resultCode,data)
  if resultCode == Activity.RESULT_OK then
    local uri=data.getData()
    if requestCode==EXPORT_HELPER and uri then
      local pfd=activity.getContentResolver().openFileDescriptor(uri, "w")
      local fileOutputStream=FileOutputStream(pfd.getFileDescriptor())
      local fileInputStream=FileInputStream(activity.getLuaDir().."/LayoutHelper.lua")
      xpcall(LuaUtil.copyFile,function(errMsg)
        print("导出失败",errMsg)
      end,fileInputStream,fileOutputStream)
      fileOutputStream.close()
      fileInputStream.close()
     elseif requestCode==PICK_PRJ and uri then
      local path=FileUriUtil.getPath(activity, uri)
      if path and File(path).isDirectory() and File(path).canRead() then
        updateProjectPath(path)
       else
        toast("路径获取失败，请选择本地文件夹")
      end
     elseif requestCode==PICK_ALY and uri then
      local path=FileUriUtil.getPath(activity, uri)
      local prjPath=prjPathEdit.text
      if path and File(path).isFile() and File(path).canRead() then
        alyPathEdit.text=prjPath and shortPath(path, prjPath) or path
       else
        toast("路径获取失败，请选择本地文件")
      end
     elseif requestCode==SELECT_OUTPUT and uri then
      local path=FileUriUtil.getPath(activity, uri)
      if path and File(path).isFile() then
        alyPathEdit.text=prjPath and shortPath(path, prjPath) or path
       else
        toast("路径获取失败，请选择本地文件")
      end
    end
  end
end