--虚拟_G
local VituralG={
  __type="VirtualObject",
}
obj2code=require "obj2code"

local vituralObjMetatable
function operationMeta(symbol)
  return function(self,secondVObj)
    local oldCallCode=rawget(self,"___callCode")
    local virtualObj=table.clone(VituralG)
    virtualObj.___callCode=oldCallCode..symbol..obj2code(secondVObj)
    setmetatable(virtualObj,vituralObjMetatable)
    return virtualObj
  end
end

vituralObjMetatable={
  __index=function(self,key)
    if key=="getSimpleName" then
      return function()
        return rawget(self,"___callCode")
      end
     elseif key=="getClass" then
      --return
    end
    --上一级调用
    local oldCallCode=rawget(self,"___callCode")
    local virtualObj=table.clone(VituralG)
    --简单的调用
    if oldCallCode then
      local simpleCallCode=type(key)=="string" and oldCallCode.."."..key
      if simpleCallCode and loadstring("return "..simpleCallCode) then
        virtualObj.___callCode=simpleCallCode
       else
        virtualObj.___callCode=oldCallCode..("[%s]"):format(obj2code(key))
      end
     else
      virtualObj.___callCode=key
    end
    setmetatable(virtualObj,vituralObjMetatable)
    return virtualObj
  end,
  __call=function(self,...)
    local params={...}
    for index,content in pairs(params)
      params[index]=obj2code(content)
    end
    local oldCallCode=rawget(self,"___callCode")
    local virtualObj=table.clone(VituralG)
    virtualObj.___callCode=oldCallCode..("(%s)"):format(table.concat(params,","))

    setmetatable(virtualObj,vituralObjMetatable)
    return virtualObj
  end,
  __type=function(self)
    return "VituralG"
  end,
  __add=operationMeta("+"),
  __sub=operationMeta("-"),
  __mul=operationMeta("*"),
  __div=operationMeta("/"),
  __mod=operationMeta("%"),
  __pow=operationMeta("^"),
  __unm=operationMeta("-"),
  __idiv=operationMeta("//"),
  __band=operationMeta("&"),
  __bor=operationMeta("|"),
  __bxor=operationMeta("~"),
  __bnot=operationMeta("~"),
  __shl=operationMeta("<<"),
  __shr=operationMeta(">>"),
  __eq=operationMeta("=="),
  __lt=operationMeta("<"),
  __le=operationMeta("<="),
}
setmetatable(VituralG,vituralObjMetatable)


return VituralG
