---@class FileUtil
local FileUtil={}

---获取父路径
function FileUtil.getParent(path)
  return path:match("(.+)/.")
end

---获取文件名
function FileUtil.getName(path)
  return path:match("([^/]+)$")
end

return FileUtil
