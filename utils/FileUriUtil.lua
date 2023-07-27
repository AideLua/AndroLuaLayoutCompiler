import "java.net.URLEncoder"
import "android.os.storage.StorageManager"

import "utils.FileUtil"

local FileUriUtil={}
local externalStorageDirs

local userId
xpcall(function()
  userId=UserHandle.myUserId()
  end,function()
  userId=0
end)

function getExternalDirPaths()
  local volumes = StorageManager.getVolumeList(userId,StorageManager.FLAG_FOR_WRITE)
  local paths = {}
  for i = 0, #volumes-1 do
    paths[i+1] = volumes[i].getPathFile().getPath()
  end
  return paths
end
externalStorageDirs=getExternalDirPaths()

--- Android 4.4往后版本 ，其中区别在 8.0download目录报错修改，华为手机uri获取不到路径处理
---@param context Context
---@param uri Uri
function FileUriUtil.getPath(context, uri)
  -- DocumentProvider
  ---@type string
  local authority=uri.getAuthority()
  if DocumentsContract.isDocumentUri(context, uri) then
    -- ExternalStorageProvider
    ---@type string
    local docId = DocumentsContract.getDocumentId(uri)
    if FileUriUtil.isExternalStorageDocument(authority) then
      local _type,path=docId:match("([^/]*):(.*)")
      if string.lower(_type)=="primary" then
        return Environment.getExternalStorageDirectory().getPath() .. "/" .. path
      end
      -- DownloadsProvider

     elseif FileUriUtil.isDownloadsDocument(authority) then
      if Build.VERSION.SDK_INT < 26 then--判断有没有超过android 8，区分开来，不然崩溃崩溃崩溃崩溃
        ---@type Uri
        local contentUri = ContentUris.withAppendedId(
        Uri.parse("content://downloads/public_downloads"), Long.parseLong(docId))
        return FileUriUtil.getColumn(context, contentUri, "_data", nil, nil)
       else
        return docId:match(":(.*)")
      end
      -- MediaProvider
     elseif FileUriUtil.isMediaDocument(authority) then
      local _type,arg=docId:match("(.*):(.*)")

      --Uri contentUri = null;
      local contentUri
      local typeLower=string.lower(_type)
      if typeLower=="image" then
        contentUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
       elseif typeLower=="video" then
        contentUri = MediaStore.Video.Media.EXTERNAL_CONTENT_URI
       elseif typeLower=="audio" then
        contentUri = MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
      end

      local selection = "_id=?";
      local selectionArgs = String({arg})

      return FileUriUtil.getColumn(context, contentUri, "_data", selection, selectionArgs)
    end
   elseif FileUriUtil.isTreeUri(uri) then
    if FileUriUtil.isExternalStorageDocument(authority) then
      local _type,path=uri.getPath():match("([^/]*):(.*)")
      if string.lower(_type)=="primary" then
        return Environment.getExternalStorageDirectory().getPath() .. "/" .. path
      end
    end

    -- MediaStore (and general)
   elseif string.lower(uri.getScheme())=="content" then
    return FileUriUtil.getColumn(context, uri, "_data", nil, nil)

    --File
   elseif string.lower(uri.getScheme())=="file" then
    return uri.getPath()
  end
  return nil
end

---@param context Context
---@param uri Uri
---@param selection string
---@param selectionArgs String[] 
---@return String
function FileUriUtil.getColumn(context, uri, column, selection, selectionArgs)
  local cursor
  --local column = "_data"
  --local projection = String({column})
  local path
  --print("正在搜索数据库")
  local success,path=pcall(function()
    cursor = context.getContentResolver().query(uri, nil, selection, selectionArgs,
    nil)
    if cursor and cursor.moveToFirst() then
      --print(dump(luajava.astable(cursor.getColumnNames())))
      local column_index = cursor.getColumnIndexOrThrow(column)
      return cursor.getString(column_index)
    end
  end)
  if (cursor) then
    cursor.close()
  end
  return success and path
end

---@param authority string
function FileUriUtil.isExternalStorageDocument(authority)
  return "com.android.externalstorage.documents"==authority
end

---@param authority string
function FileUriUtil.isDownloadsDocument(authority)
  return "com.android.providers.downloads.documents"==authority

end

---@param authority string
function FileUriUtil.isMediaDocument(authority)
  return "com.android.providers.media.documents"==authority
end

function FileUriUtil.isTreeUri(uri)
  local paths = uri.getPathSegments()
  return paths.size() >=2 and "tree"==paths[0]
end


--[[
    public static String getDataColumn(Context context, Uri uri, String selection,
                                       String[] selectionArgs) {
        Cursor cursor = null;
        final String column = "_data";
        final String[] projection = {column};
        try {
            cursor = context.getContentResolver().query(uri, projection, selection, selectionArgs,
                                                        null);
            if (cursor != null && cursor.moveToFirst()) {
                final int column_index = cursor.getColumnIndexOrThrow(column);
                return cursor.getString(column_index);
            }
        } finally {
            if (cursor != null)
                cursor.close();
        }
        return null;

    }



    public static boolean isGooglePhotosUri(String authority) {
        return "com.google.android.apps.photos.content".equals(authority);
    }

    public static boolean isHuaWeiUri(String authority) {
        return "com.huawei.hidisk.fileprovider".equals(authority)||"com.huawei.filemanager.share.fileprovider".equals(authority);
    }


    public static boolean isExternalStorageDocument(String authority) {
        return "com.android.externalstorage.documents".equals(authority);

    }

    public static boolean isDownloadsDocument(String authority) {
        return "com.android.providers.downloads.documents".equals(authority);

    }

    public static boolean isMediaDocument(String authority) {
        return "com.android.providers.media.documents".equals(authority);

    }

   
     ---获取真实路径
     ---@return String
    function getRealFilePath(Context context, final Uri uri) {
        if (null == uri)
            return null;
        final String scheme = uri.getScheme();
        String data = null;
        if (scheme == null)
            data = uri.getPath();
        else if (ContentResolver.SCHEME_FILE.equals(scheme)) {
            data = uri.getPath();
        } else if (ContentResolver.SCHEME_CONTENT.equals(scheme)) {
            Cursor cursor = context.getContentResolver().query(uri, new String[]{MediaStore.Images.ImageColumns.DATA}, null, null, null);
            if (null != cursor) {
                if (cursor.moveToFirst()) {
                    int index = cursor.getColumnIndex(MediaStore.Images.ImageColumns.DATA);
                    if (index > -1) {
                        data = cursor.getString(index);
                    }
                }
                cursor.close();
            }
        }
        return data;
    }


]]

---路径转换成文档uri，如果不能转换则返回nil
---@param path 路径
function FileUriUtil.path2DocumentUri(path,isTree)
  local _type=isTree and "tree" or "document"
  local uriText
  for index=1,#externalStorageDirs do
    local extDirPath=externalStorageDirs[index]
    if String(path).startsWith(extDirPath) then
      local relativePath=string.sub(path,string.len(extDirPath)+2)
      local encodedRelPath=URLEncoder.encode(relativePath,"utf-8")
      local sdcName
      if Environment.isExternalStorageEmulated() then
        sdcName="primary"
       else
        sdcName=FileUtil.getName(relativePath)
      end
      uriText=string.format("content://com.android.externalstorage.documents/%s/%s:%s",_type,sdcName,encodedRelPath)
      break
    end
  end
  if uriText then
    return Uri.parse(uriText)
  end
  return nil
end
return FileUriUtil
