--将lua对象转换为代码
return function(obj)
  if type(obj)=="VituralG" then
    return obj.___callCode
   elseif type(obj)=="function" then
    return ("load(\"%s\")"):format(string.dump(obj))
   else
    return dump(obj):match("(.+) ;")
  end
end
 