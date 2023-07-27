local DialogHelper={}

function DialogHelper.setMessageIsSelectable(dialog,selectable)
  local messageView=dialog.findViewById(android.R.id.message)
  assert(messageView,"There are no messages in this dialog box")
  messageView.setTextIsSelectable(selectable)
end

return DialogHelper
