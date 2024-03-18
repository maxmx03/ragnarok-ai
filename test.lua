MyID = myid
local msg = GetMsg(myid)     -- Receive messages
local rmsg = GetResMsg(myid) -- Receive reserved message, i.e. queued command
ProcessCommand(msg)          -- Perform user’s commands

-- Save reserved message
if msg[1] == NONE_CMD then
  if rmsg[1] ~= NONE_CMD then
    if List.size(ResCmdList) < 10 then -- Set maximum number of messages that can be saved
      List.pushright(ResCmdList, rmsg)
    end
  end
else
  List.clear(ResCmdList) -- Cancel previous reserved commands each time a new command is received
end
