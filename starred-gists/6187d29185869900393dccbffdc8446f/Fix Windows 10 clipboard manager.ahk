#SingleInstance,Force
#NoEnv
;********************Fix stupid Windows clipboard***********************************
#IfWinActive ahk_class Shell_LightDismissOverlay
enter:: ;when hit enter key
Send, {space} ;send the space key
return ;Stop from moving forward
