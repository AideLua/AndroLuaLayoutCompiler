
sdcardPath=Environment.getExternalStorageDirectory().getPath()--SD卡的目录

--- 相对路径转绝对路径
---@param path string 要转换的相对路径
---@param localPath string 相对的目录
function rel2AbsPath(path, localPath)
  if path:sub(1, 1) == "/" then
    return path
   elseif localPath:sub(#localPath, #localPath) == "/"
    return localPath .. path
   else
    return localPath .. "/" .. path
  end
end

---缩短路径，绝对路径转换为相对路径，如果该路径不能转换为相对路径，则原封不动返回该路径
---@param path string 要转换的路径
---@param basePath string 当前文件夹
function shortPath(path,basePath)
  --过滤末尾的/
  if basePath:sub(#basePath,#basePath)=="/" then
    basePath=basePath:sub(1,#basePath-1)
  end
  if basePath and path:sub(1,#basePath)==basePath then
    return string.sub(path,string.len(basePath)+2)
   else
    return path
  end
end

---路径转换成文档uri
---@param path 路径
function path2DocumentUri(path)
  if String(path).startsWith(sdcardPath) then
    local relativePath=string.sub(path,string.len(sdcardPath)+2):gsub("/","%%2f")
    return Uri.parse("content://com.android.externalstorage.documents/document/primary:"..relativePath)
  end
end

function getFileNameWithoutExtensionName(path)
  local name=File(path).getName()
  return name:match("(.+)%.") or name
end

function buildEnvPath(runDirPath)
  if runDirPath then
    local envPath=runDirPath.."/?.lua;"
    ..runDirPath.."/?/init.lua;"
    ..runDirPath.."/lua/?.lua;"
    ..runDirPath.."/lua/?/init.lua;"
    envPath=envPath and envPath..envPath:gsub("%.lua;",".aly;")
    return envPath
  end
end

function toast(text)
  Toast.makeText(activity, text,Toast.LENGTH_SHORT).show()
end

function readFile(path)
  local file=io.open(path)
  local content=file:read("*a")
  file:close()
  return content
end

function decodeTemplateCode(templateCode)
  local content=templateCode:gsub("{{(.-)}}",function(key)
    return assert(loadstring("return "..key))()
  end)
  return content
end