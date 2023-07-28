import "java.io.File"
local _M={}
setmetatable(_M,_M)
_M.__VERSION="1.3(alpha)"
_M.__VERSION_CODE=1301
_M.__AUTHOR="Jesse205"
_M.__DESCRIPTION="Compile AndroLua layout"
local VituralG=require "VituralG"
local obj2code=require "obj2code"

--local require=require
local luajava = luajava
--local table=require "table"
local insert = table.insert
local new = luajava.new
local bindClass = luajava.bindClass

local ltrs={}
local type=type
local context=activity or service

--自动适配当前上下文
local contextCode="activity"

local toint={
  --android:drawingCacheQuality
  auto=0,
  low=1,
  high=2,

  --android:importantForAccessibility
  auto=0,
  yes=1,
  no=2,

  --android:layerType
  none=0,
  software=1,
  hardware=2,

  --android:layoutDirection
  ltr=0,
  rtl=1,
  inherit=2,
  locale=3,

  --android:scrollbarStyle
  insideOverlay=0x0,
  insideInset=0x01000000,
  outsideOverlay=0x02000000,
  outsideInset=0x03000000,

  --android:visibility
  visible=0,
  invisible=4,
  gone=8,

  wrap_content=-2,
  fill_parent=-1,
  match_parent=-1,
  wrap=-2,
  fill=-1,
  match=-1,

  --android:autoLink
  none=0x00,
  web=0x01,
  email=0x02,
  phon=0x04,
  map=0x08,
  all=0x0f,

  --android:orientation
  vertical=1,
  horizontal= 0,

  --android:gravity
  axis_clip = 8,
  axis_pull_after = 4,
  axis_pull_before = 2,
  axis_specified = 1,
  axis_x_shift = 0,
  axis_y_shift = 4,
  bottom = 80,
  center = 17,
  center_horizontal = 1,
  center_vertical = 16,
  clip_horizontal = 8,
  clip_vertical = 128,
  display_clip_horizontal = 16777216,
  display_clip_vertical = 268435456,
  --fill = 119,
  fill_horizontal = 7,
  fill_vertical = 112,
  horizontal_gravity_mask = 7,
  left = 3,
  no_gravity = 0,
  relative_horizontal_gravity_mask = 8388615,
  relative_layout_direction = 8388608,
  right = 5,
  start = 8388611,
  top = 48,
  vertical_gravity_mask = 112,
  ["end"] = 8388613,

  --android:textAlignment
  inherit=0,
  gravity=1,
  textStart=2,
  textEnd=3,
  textCenter=4,
  viewStart=5,
  viewEnd=6,

  --android:inputType
  none=0x00000000,
  text=0x00000001,
  textCapCharacters=0x00001001,
  textCapWords=0x00002001,
  textCapSentences=0x00004001,
  textAutoCorrect=0x00008001,
  textAutoComplete=0x00010001,
  textMultiLine=0x00020001,
  textImeMultiLine=0x00040001,
  textNoSuggestions=0x00080001,
  textUri=0x00000011,
  textEmailAddress=0x00000021,
  textEmailSubject=0x00000031,
  textShortMessage=0x00000041,
  textLongMessage=0x00000051,
  textPersonName=0x00000061,
  textPostalAddress=0x00000071,
  textPassword=0x00000081,
  textVisiblePassword=0x00000091,
  textWebEditText=0x000000a1,
  textFilter=0x000000b1,
  textPhonetic=0x000000c1,
  textWebEmailAddress=0x000000d1,
  textWebPassword=0x000000e1,
  number=0x00000002,
  numberSigned=0x00001002,
  numberDecimal=0x00002002,
  numberPassword=0x00000012,
  phone=0x00000003,
  datetime=0x00000004,
  date=0x00000014,
  time=0x00000024,

  --android:imeOptions
  normal=0x00000000,
  actionUnspecified=0x00000000,
  actionNone=0x00000001,
  actionGo=0x00000002,
  actionSearch=0x00000003,
  actionSend=0x00000004,
  actionNext=0x00000005,
  actionDone=0x00000006,
  actionPrevious=0x00000007,
  flagNoFullscreen=0x2000000,
  flagNavigatePrevious=0x4000000,
  flagNavigateNext=0x8000000,
  flagNoExtractUi=0x10000000,
  flagNoAccessoryAction=0x20000000,
  flagNoEnterAction=0x40000000,
  flagForceAscii=0x80000000,

}

local scaleType={
  --android:scaleType
  matrix=0,
  fitXY=1,
  fitStart=2,
  fitCenter=3,
  fitEnd=4,
  center=5,
  centerCrop=6,
  centerInside=7,
}


local rules={
  layout_above=2,
  layout_alignBaseline=4,
  layout_alignBottom=8,
  layout_alignEnd=19,
  layout_alignLeft=5,
  layout_alignParentBottom=12,
  layout_alignParentEnd=21,
  layout_alignParentLeft=9,
  layout_alignParentRight=11,
  layout_alignParentStart=20,
  layout_alignParentTop=10,
  layout_alignRight=7,
  layout_alignStart=18,
  layout_alignTop=6,
  layout_alignWithParentIfMissing=0,
  layout_below=3,
  layout_centerHorizontal=14,
  layout_centerInParent=13,
  layout_centerVertical=15,
  layout_toEndOf=17,
  layout_toLeftOf=0,
  layout_toRightOf=1,
  layout_toStartOf=16
}


local types={
  px=0,
  dp=1,
  sp=2,
  pt=3,
  ["in"]=4,
  mm=5
}

local function checkType(v)
  local n,ty=string.match(v,"^(%-?[%.%d]+)(%a%a)$")
  return tonumber(n),types[ty]
end

--[[
local function checkPercent(v)
  local n,ty=string.match(v,"^(%-?[%.%d]+)%%([wh])$")
  if ty==nil then
    return nil
   elseif ty=="w" then
    return tonumber(n)*W/100
   elseif ty=="h" then
    return tonumber(n)*H/100
  end
end]]

local function checkPercentCode(v)
  local n,ty=string.match(v,"^(%-?[%.%d]+)%%([wh])$")
  if ty==nil then
    return nil
   elseif ty=="w" then
    return ("%s*LayoutHelper.PERCENT_W"):format(tonumber(n))
   elseif ty=="h" then
    return ("%s*LayoutHelper.PERCENT_H"):format(tonumber(n))
  end
end


local function split(s,t)
  local idx=1
  local l=#s
  return function()
    local i=s:find(t,idx)
    if idx>=l then
      return nil
    end
    if i==nil then
      i=l+1
    end
    local sub=s:sub(idx,i-1)
    idx=i+1
    return sub
  end
end

local function checkint(s)
  local ret=0
  for n in split(s,"|") do
    if toint[n] then
      ret=ret | toint[n]
     else
      return nil
    end
  end
  return ret
end

local function checkNumberCode(var)
  if type(var) == "string" then
    if var=="true" then
      return true
     elseif var=="false" then
      return false
    end

    if toint[var] then
      return toint[var]
    end

    local p=checkPercentCode(var)
    if p then
      return p
    end

    local i=checkint(var)
    if i then
      return i
    end

    local h=string.match(var,"^#(%x+)$")
    if h then
      local c=tonumber(h,16)
      if c then
        if #h<=6 then
          return c-0x1000000
         elseif #h<=8 then
          if c>0x7fffffff then
            return c-0x100000000
           else
            return c
          end
        end
      end
    end

    local n,ty=checkType(var)
    if ty then
      return ("TypedValue.applyDimension(%s,%s,LayoutHelper.dm)"):format(ty,n)
    end
  end
end

local function checkValueCode(var)
  if var~=nil then
    return tonumber(var) or checkNumberCode(var) or obj2code(var)
  end
end

local function checkValuesCode(...)
  local vars={...}
  for n=1,#vars do
    vars[n]=checkValueCode(vars[n])
  end
  return table.concat(vars,",")
end

local function getattr(s)
  return android_R.attr[s]
end

local function checkattr(s)
  local e,s=pcall(getattr,s)
  if e then
    return s
  end
  return nil
end

local function getIdentifier(name)
  return context.getResources().getIdentifier(name,nil,nil)
end

local function dump2 (t)
  local _t={}
  table.insert(_t,tostring(t))
  table.insert(_t,"\t{")
  for k,v in pairs(t) do
    if type(v)=="table" then
      table.insert(_t,"\t\t"..tostring(k).."={"..tostring(v[1]).." ...}")
     else
      table.insert(_t,"\t\t"..tostring(k).."="..tostring(v))
    end
  end
  table.insert(_t,"\t}")
  t=table.concat(_t,"\n")
  return t
end

local confuse=false
local function VariableNameProviderBuilder(level)
  local used={}
  local index
  if confuse then
    index=1--混淆
  end
  setmetatable(used,{__index=function(self,key)
      local name
      if confuse then
        index=index+1
        name=string.rep("⠀",index)--混淆
       else
        name=key
      end
      if level then
        name=name..level
      end
      name="varsMap."..name
      rawset(self,key,name)
      return name
  end})
  return used
end

local compilelayout
local function setattributeCode(view,k,v,varNameProvider,level,paths,hasAdapter)
  if type(v)=="userdata" then
    print("不支持的属性",k,":","Object")
    return
  end
  if k=="layout_x" then
    return varNameProvider.params..".x="..checkValueCode(v)
   elseif k=="layout_y" then
    return varNameProvider.params..".y="..checkValueCode(v)
   elseif k=="layout_weight" then
    return varNameProvider.params..".weight="..checkValueCode(v)
   elseif k=="layout_gravity" then
    return varNameProvider.params..".gravity="..checkValueCode(v)
   elseif k=="layout_marginStart" then
    return varNameProvider.params..(".setMarginStart(%s)"):format(checkValueCode(v))
   elseif k=="layout_marginEnd" then
    return varNameProvider.params..(".setMarginEnd(%s)"):format(checkValueCode(v))
   elseif rules[k] and (v==true or v=="true") then
    return varNameProvider.params..(".addRule(%s)"):format(rules[k])
   elseif rules[k] then
    return varNameProvider.params..(".addRule(%s,LayoutHelper.ids[%s])"):format(rules[k],obj2code(v))
   elseif k=="items" then --创建列表项目
    --print("不受支持的属性:","items")
    if type(v)=="table" then
      if hasAdapter then
        return ("%s.adapter.addAll(%s)"):format(varNameProvider.view,obj2code(v))
       else
        return ("%s.setAdapter(ArrayListAdapter(%s,android.R.layout.simple_list_item_1, String(%s)))"):format(varNameProvider.view,contextCode,obj2code(v))
      end
     elseif type(v)=="function" then
      if hasAdapter then
        return ("%s.adapter.addAll(%s())"):format(varNameProvider.view,obj2code(v))
       else
        return ("%s.setAdapter(ArrayListAdapter(%s,android.R.layout.simple_list_item_1, String(%s())))"):format(varNameProvider.view,contextCode,obj2code(v))
      end
     elseif type(v)=="string" then
      local compiledContent=("%s=rawget(root,%s) or rawget(_G,%s)\n"):format(varNameProvider.value,obj2code(v),obj2code(v))
      if hasAdapter then
        compiledContent=compiledContent..("%s.adapter.addAll(%s())"):format(varNameProvider.view,varNameProvider.value)
       else
        compiledContent=compiledContent..("%s.setAdapter(ArrayListAdapter(%s,android.R.layout.simple_list_item_1, String(%s())))"):format(varNameProvider.view,contextCode,varNameProvider.value)
      end
      return compiledContent
    end
   elseif k=="pages" and type(v)=="table" then --创建页项目

    local compiledContent=("%s={}\n"):format(varNameProvider.ps)
    for n,o in ipairs(v) do
      local tp=type(o)
      if tp=="string" or tp=="table" then
        local subVarNameProvider=VariableNameProviderBuilder(level+1)
        subVarNameProvider.group=varNameProvider.view
        local subContent,subVarNameProvider=compilelayout(o,view.getClass(),level+1,subVarNameProvider,paths)
        compiledContent=compiledContent..
        subContent..([[table.insert(%s,%s)
%s=nil
]]):format(varNameProvider.ps,subVarNameProvider.view,subVarNameProvider.view)

       else
        print("不受支持的属性:","pages:Other")
        --table.insert(ps,o)
      end
    end
    compiledContent=compiledContent..([[
%s.setAdapter(ArrayPageAdapter(View(%s)))
%s=nil]]):format(varNameProvider.view,varNameProvider.ps,varNameProvider.ps)
    return compiledContent
   elseif k=="textSize" then
    if tonumber(v) then
      return ("%s.setTextSize(%s)"):format(varNameProvider.view,tonumber(v))
     elseif type(v)=="string" then
      local n,ty=checkType(v)--n和ty肯定是number类型
      if ty then
        return ("%s.setTextSize(%s,%s)"):format(varNameProvider.view,ty,n)
       else
        return ("%s.setTextSize(%s)"):format(varNameProvider.view,v)
      end
     else
      return ("%s.setTextSize(%s)"):format(varNameProvider.view,obj2code(v))
    end
   elseif k=="textAppearance" then
    return ("%s.setTextAppearance(%s,%s)"):format(varNameProvider.view,contextCode,checkattr(v))
   elseif k=="ellipsize" then
    return ("%s.setEllipsize(TextUtils.TruncateAt.%s)"):format(varNameProvider.view,string.upper(v))
   elseif k=="url" then
    return ("%s.loadUrl(%s)"):format(varNameProvider.view,obj2code(k))
   elseif k=="src" then
    if v:find("^%?") then
      return ("%s.setImageResource(%s)"):format(varNameProvider.view,getIdentifier(v:sub(2,-1)))
     elseif v:find("^https?://") then
      return ([=[task([[require "import" url=... return loadbitmap(url)]],%s,function(bmp)%s.setImageBitmap(bmp)end)]=]):format(obj2code(v),varNameProvider.view)
     else
      return ("%s.setImageBitmap(loadbitmap(%s))"):format(varNameProvider.view,obj2code(v))
    end
   elseif k=="scaleType" then
    return ("%s.setScaleType(LayoutHelper.scaleTypes[%s])"):format(varNameProvider.view,scaleType[v])
   elseif k=="background" then
    --print("不受支持的属性:","background")
    if type(v)=="string" then
      if v:find("^%?") then
        return ("%s.setBackgroundResource(%s)"):format(varNameProvider.view,getIdentifier(v:sub(2,-1)))
       elseif v:find("^#") then
        return ("%s.setBackgroundColor(%s)"):format(varNameProvider.view,checkNumberCode(v))
        --[[
       elseif rawget(root,v) or rawget(_G,v) then
        v=rawget(root,v) or rawget(_G,v)
        if type(v)=="function" then
          setBackground(view,LuaDrawable(v))
         elseif type(v)=="userdata" then
          setBackground(view,v)
        end]]
       else
        if v:find("%.9%.png") then
          return ("LayoutHelper.setBackground(%s,NineBitmapDrawable(loadbitmap(%s)))"):format(varNameProvider.view,obj2code(v))
         else
          return ("LayoutHelper.setBackground(%s,LuaBitmapDrawable(%s,%s))"):format(varNameProvider.view,contextCode,obj2code(v))
        end
      end
     elseif type(v)=="userdata" then
      --setBackground(view,v)
      print("不受支持的属性:","background:Object")
     elseif type(v)=="table" and v.__type=="VirtualObject" then
      return ("LayoutHelper.setBackground(%s,%s)"):format(varNameProvider.view,v)
     elseif type(v)=="number" then
      return ("LayoutHelper.setBackground(%s,%s)"):format(varNameProvider.view,v)
    end
   elseif k=="onClick" then --设置onClick事件接口

    local listenerCode
    if type(v)=="function" then
      listenerCode=("View.OnClickListener{onClick=%s}"):format(obj2code(v))
      --print("不受支持的属性:","onClick:function")
     elseif type(v)=="userdata" then
      --listener=v
      listenerCode="--不受支持的属性 onClick:Object"
      print("不受支持的属性:","onClick:Object")
     elseif type(v)=="table" and v.__type=="VirtualObject" then
      listenerCode=obj2code(v)
     elseif type(v)=="string" then
      listenerCode=("LayoutHelper.getClickListener(root,%s)"):format(obj2code(v))
    end
    if listenerCode then
      return ("%s.setOnClickListener(%s)"):format(varNameProvider.view,listenerCode)
    end

   elseif k=="password" and (v=="true" or v==true) then
    return ("%s.setInputType(0x81)"):format(varNameProvider.view)
   elseif type(k)=="string" and not(k:find("layout_")) and not(k:find("padding")) and k~="style" then --设置属性
    k=string.gsub(k,"^(%w)",function(s)return string.upper(s)end)
    if k=="Text" or k=="Title" or k=="Subtitle" then
      return ("%s.set%s(%s)"):format(varNameProvider.view,k,obj2code(v))
     elseif not k:find("^On") and not k:find("^Tag") and type(v)=="table" and v.__type~="VirtualObject" then
      return ("%s.set%s(%s)"):format(varNameProvider.view,k,checkValuesCode(unpack(v)))
     else
      return ("%s.set%s(%s)"):format(varNameProvider.view,k,checkValueCode(v))
    end
  end
end

local function copytable(f,t,b)
  for k,v in pairs(f) do
    if k==1 then
     elseif b or t[k]==nil then
      t[k]=v
    end
  end
end

local function loadtable(name,paths)
  local path,msg
  if File(name).isFile() then
    path=name
   else
    path,msg=package.searchpath(name,paths)
  end

  if path then
    return assert(loadfile(path,"bt",VituralG))()
   else
    error("Can't find "..name..".",0)
  end
end

--编译布局
function compilelayout(t,groupClass,level,varNameProvider,paths)
  if type(t)=="string" then
    t=loadtable(t,paths)
   elseif type(t)~="table" then
    error(string.format("compilelayout error: Fist value Must be a table, checked import layout.",0))
  end
  local view,style
  local compiledContent=""

  if t.style then
    if t.style:find("^%?") then
      style=getIdentifier(t.style:sub(2,-1))
     else
      local st,sty=pcall(require,t.style)
      if st then
        --copytable(sty,t)
        setmetatable(t,{__index=sty})
       else
        style=checkattr(t.style)
      end
    end
  end
  if not t[1] then
    error(string.format("compilelayout error: Fist value Must be a Class, checked import package.\n\tat %s",dump2(t)),0)
  end
  varNameProvider=varNameProvider or VariableNameProviderBuilder(level)

  --创建view
  local reallyObj=type(t[1])=="VituralG" and _G[t[1].___callCode]
  local viewSimpleName=t[1].___callCode
  if reallyObj then
    if style then
      view = reallyObj(context,nil,style)
      compiledContent=compiledContent..("%s=%s(%s,nil,%s)\n"):format(varNameProvider.view,viewSimpleName,contextCode,style)
     else
      view = reallyObj(context) --创建view
      compiledContent=compiledContent..("%s=%s(%s)\n"):format(varNameProvider.view,viewSimpleName,contextCode)
    end
   else
    compiledContent=compiledContent..string.format("--WARNING: %s not found, the following line of code may crash.\n",viewSimpleName)
    if style then
      compiledContent=compiledContent..("%s=%s(%s,nil,%s)\n"):format(varNameProvider.view,viewSimpleName,contextCode,style)
     else
      compiledContent=compiledContent..("%s=%s(%s)\n"):format(varNameProvider.view,viewSimpleName,contextCode)
    end
    --print(string.format("compilelayout error: Fist value Must be a Class, checked import package.\n\tat %s",dump2(t)),0)
  end

  local widthCode,heightCode=checkValueCode(t.layout_width) or -2,checkValueCode(t.layout_height) or -2
  if groupClass then
    local simpleName=groupClass.getSimpleName()
    compiledContent=compiledContent..("%s=%s.LayoutParams(ViewGroup.LayoutParams(%s,%s))\n"):format(varNameProvider.params,simpleName,widthCode,heightCode)
   else
    compiledContent=compiledContent..([[
%s=ViewGroup.LayoutParams(%s,%s)
%s=%s and %s.LayoutParams(%s) or ViewGroup.LayoutParams(%s)
]]):format(varNameProvider.params,widthCode,heightCode,
    varNameProvider.params,
    varNameProvider.group,varNameProvider.group,varNameProvider.params,
    varNameProvider.params)
  end
  --设置layout_margin属性
  if t.layout_margin or t.layout_marginStart or t.layout_marginEnd or t.layout_marginLeft or t.layout_marginTop or t.layout_marginRight or t.layout_marginBottom then
    compiledContent=compiledContent..varNameProvider.params..(".setMargins(%s)\n"):format(
    checkValuesCode(t.layout_marginLeft or t.layout_margin or 0,
    t.layout_marginTop or t.layout_margin or 0,
    t.layout_marginRight or t.layout_margin or 0,
    t.layout_marginBottom or t.layout_margin or 0))
  end
  --设置padding属性
  if t.padding and type(t.padding)=="table" then
    compiledContent=compiledContent..("%s.setPadding(%s)\n"):format(varNameProvider.view,checkValuesCode(unpack(t.padding)))
   elseif t.padding or t.paddingLeft or t.paddingTop or t.paddingRight or t.paddingBottom then
    compiledContent=compiledContent..("%s.setPadding(%s)\n"):format(varNameProvider.view,checkValuesCode(t.paddingLeft or t.padding or 0, t.paddingTop or t.padding or 0, t.paddingRight or t.padding or 0, t.paddingBottom or t.padding or 0))
  end
  if t.paddingStart or t.paddingEnd then
    compiledContent=compiledContent..("%s.setPaddingRelative(%s)\n"):format(varNameProvider.view,checkValuesCode(t.paddingStart or t.padding or 0, t.paddingTop or t.padding or 0, t.paddingEnd or t.padding or 0, t.paddingBottom or t.padding or 0))
  end
  local hasAdapter
  for k,v in pairs(t) do
    if k~=1 then
      if tonumber(k) and (type(v)=="table" or type(v)=="string") then --创建子view
        if view and luajava.instanceof(view,AdapterView) then
          --添加适配器
          local adapterContent=(type(v)=="string" and "require(%s)" or "%s"):format(obj2code(v))
          compiledContent=compiledContent..
          ("%s.adapter=LuaAdapter(%s,%s)"):format(varNameProvider.view,contextCode,adapterContent)
          hasAdapter=true
         else
          local subVarNameProvider=VariableNameProviderBuilder(level+1)
          subVarNameProvider.group=varNameProvider.view
          local subContent,subVarNameProvider=compilelayout(v,t[1],level+1,subVarNameProvider,paths)
          compiledContent=compiledContent..
          subContent..([[%s.addView(%s)
--%s=nil
]]):format(varNameProvider.view,subVarNameProvider.view,subVarNameProvider.view)
        end
       elseif k=="id" then --创建view的全局变量
        compiledContent=compiledContent..([[
rawset(root,%s,%s)
%s.setId(LayoutHelper.newId(%s))
]]):format(obj2code(v),varNameProvider.view,varNameProvider.view,obj2code(v))

       else
        local e,s=pcall(setattributeCode,view,k,v,varNameProvider,level,paths,hasAdapter)
        if e then
          if s then--没有报错但不代表有东西
            compiledContent=compiledContent..s.."\n"
          end
         else
          local _,i=s:find(":%d+:")
          s=s:sub(i or 1,-1)
          local t,du=pcall(dump2,t)
          print(string.format("compilelayout error %s \n\tat %s\n\tat  key=%s value=%s\n\tat %s",s,view.toString(),k,v,du or ""),0)
        end
      end
    end
  end
  compiledContent=compiledContent..([[%s.setLayoutParams(%s)
--%s=nil
]]):format(varNameProvider.view,varNameProvider.params,
  varNameProvider.params)
  return compiledContent,varNameProvider
end

function _M.__call(self,t,paths)
  local varNameProvider=VariableNameProviderBuilder(0)
  varNameProvider.group="group"
  local content=compilelayout(t,nil,0,varNameProvider,paths or "")
  return [[local LayoutHelper=require "LayoutHelper"
return function(root,group)
  local varsMap={}
  root=root or _G
  ]]..content..([[
  --varsMap=nil
  return %s
end]]):format(varNameProvider.view)
end

return _M