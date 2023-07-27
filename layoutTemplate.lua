--布局模板
local layoutTemplate={}

function layoutTemplate.itemTitle(title)
  return {
    TextView;
    layout_width="fill";
    text=title;
    layout_margin="8dp";
    layout_marginLeft="16dp";
    layout_marginRight="16dp";
    textColor=colorAccent;
  }
end

function layoutTemplate.itemHelperText(text)
  return {
    TextView;
    text=text;
    textColor=textColorSecondary;
    layout_marginLeft="16dp";
    layout_marginRight="16dp";
    layout_marginBottom="8dp";
    textSize="12sp";
  };
end

return layoutTemplate
