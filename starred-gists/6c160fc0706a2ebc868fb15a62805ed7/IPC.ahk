/* Title:	IPC
			*Inter-process Communication*.
 */

/*
 Function:    Send
          Send the message to another process (receiver).

 Parameters:
          PidOrName   - Process name or ID
          Data      - Data to be sent, by default empty. Optional.
          Port      - Port, by default 100. Positive integer. Optional.
          DataSize    - If this parameter is used, Data contains pointer to the buffer holding binary data.
                  Omit this parameter to send textual messages to the receiver.               

 Remarks:
         The data being passed must not contain pointers or other references to objects not accessible to the script receiving the data.
         While this message is being sent, the referenced data must not be changed by another thread of the sending process.
         The receiving script should consider the data read-only. The receiving script should not free the memory referenced by Data parameter.
         If the receiving script must access the data after function returns, it must copy the data into a local buffer.

 Returns:
         Returns EMPTY / FALSE on success. Error message on failure.
 */
IPC_Send(PidOrName, Data="", Port=100, DataSize="") {
   static WM_COPYDATA = 74, INT_MAX=2147483647
   if Port not between 0 AND %INT_MAX%
      return A_ThisFunc "> Port number is not in a positive integer range: " Port
   
   Process, Exist, %PidOrName%
   if (!PidOrName || !(PID := ErrorLevel))
      return A_ThisFunc "> Process not found: " PidOrName
   
   if (DataSize = "")
      DataSize := (StrLen(Data)+1) * (!!A_IsUnicode + 1), pData := &Data, Port := -Port         ;use negative port for textual messages
   else pData := Data

   VarSetCapacity(COPYDATA, 3*A_PtrSize)
    , NumPut(Port,      COPYDATA, 0, "Int")
    , NumPut(DataSize, COPYDATA, A_PtrSize, "UInt")
    , NumPut(pData,   COPYDATA, 2*A_PtrSize, "Ptr")
      
   PrevDetectHiddenWindows := A_DetectHiddenWindows
   DetectHiddenWindows, On
   SendMessage, WM_COPYDATA, DllCall("GetCurrentProcessId"), &COPYDATA,, ahk_pid %PID%
   DetectHiddenWindows, %PrevDetectHiddenWindows%
   
   return ErrorLevel="FAIL" || !ErrorLevel ? A_ThisFunc "> SendMessage failed, ErrorLevel=" ErrorLevel : false
}

/*
  Function:    SetHandler
           Set the data handler.
 
  Parameters:
           Handler - Function that will be called when data is received.                
 
  Handler:
  >          Handler(PID, Data, Port, DataSize)

          PID   - Process ID of the process passing data.
          Data   - Data that is received.
          Port   - Data port.
          DataSize - If DataSize is not empty, Data is pointer to the actuall data. Otherwise Data is textual message.
 */
IPC_SetHandler( Handler ){
   static WM_COPYDATA = 74

   if !IsFunc( Handler )
      return A_ThisFunc "> Invalid handler: " Handler
   
   OnMessage(WM_COPYDATA, "IPC_onCopyData")
   IPC_onCopyData(Handler, "")
}


IPC_onCopyData(WParam, LParam) {
   static Handler
   if Lparam =
      return  Handler := WParam
      
   port := NumGet(Lparam+0, 0, "Int"), data := NumGet(Lparam+2*A_PtrSize, 0, "Ptr")
   if port < 0
      data := DllCall("MulDiv", "Int", data, "Int",1, "Int", 1, "str"), port := -port
   else size := NumGet(LParam+A_PtrSize, 0, "UInt")

   %handler%(WParam, data, port, size)
   return 1
}

/* 
 Group: About 
 	o IPC ver ??? by majkinetor.
	o Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/>
 */