local LayoutHelper={}
LayoutHelper._VERSION="1.1(alpha01)"
LayoutHelper._VERSION_CODE=1101

import "android.text.TextUtils"
import "android.util.TypedValue"
import "android.content.Context"
import "android.util.DisplayMetrics"
local ScaleType=ImageView.ScaleType
local OnClickListener=View.OnClickListener

local context=activity or service
local wm =context.getSystemService(Context.WINDOW_SERVICE)
local outMetrics = DisplayMetrics()
wm.getDefaultDisplay().getMetrics(outMetrics)
local W = outMetrics.widthPixels
local H = outMetrics.heightPixels
LayoutHelper.W=W
LayoutHelper.H=H
LayoutHelper.PERCENT_W=W/100
LayoutHelper.PERCENT_H=H/100

local dm=context.getResources().getDisplayMetrics()
LayoutHelper.dm=dm
LayoutHelper.id=0x7f000000
LayoutHelper.ids={}
LayoutHelper.scaleTypes=ScaleType.values()
LayoutHelper.ltrs={}

function LayoutHelper.getClickListener(root,v)
  local listener
  if LayoutHelper.ltrs[v] then
    listener=LayoutHelper.ltrs[v]
   else
    local l=rawget(root,v)
    if type(l)=="function" then
      listener=OnClickListener{onClick=l}
     elseif type(l)=="userdata" then
      listener=l
     else
      listener=OnClickListener{onClick=function(a)(root[v])(a)end}
    end
    LayoutHelper.ltrs[v]=listener
  end
  return listener
end

function LayoutHelper.newId()
  LayoutHelper.id=LayoutHelper.id+1
  return LayoutHelper.id
end

local ver = luajava.bindClass("android.os.Build").VERSION.SDK_INT;
function LayoutHelper.setBackground(view,bg)
  if ver<16 then
    view.setBackgroundDrawable(bg)
   else
    view.setBackground(bg)
  end
end

return LayoutHelper
