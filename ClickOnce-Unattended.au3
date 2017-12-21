#cs ----------------------------------------------------------------------------

 Title: ClickOnce Unattended
 Version: 0.1
 AutoIt Version: 3.3.14.2
 Author:         Eduardo Mozart de Oliveira

 Script Function:
	Silent installer for ClickOnce aplications
	https://www.autoitscript.com/forum/topic/58770-need-simple-example-of-command-line-parameters/

#ce ----------------------------------------------------------------------------

#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include "autoit-processclass\ProcessClass.au3"

AutoItSetOption ( "TrayIconDebug", 1 )
Opt("WinWaitDelay", 250)
;OnAutoItExitRegister("OnAutoItExit")
HotKeySet("{ESCAPE}", "OnAutoItExit")

If $CmdLine[0] = 0 Then Main(_FileOpenDialog())
If $CmdLine[0] > 1 Then help()

Func Main($ClickOnceStub)
   If Not FileExists($ClickOnceStub) Then
	  ConsoleWrite("ERROR: File " & $ClickOnceStub & " not found.")
	  Exit 1
   EndIf

   EnvSet("SEE_MASK_NOZONECHECKS","1")
   ShellExecute($ClickOnceStub)
   EnvSet("SEE_MASK_NOZONECHECKS","0")

   ProcessWait("dfsvc.exe")
   AdlibRegister("OnAutoItExitAdlib")

   While _Process2Win("dfsvc.exe") = -1
	  Sleep(250)
	  ConsoleWrite('_Process2Win("dfsvc.exe"): ' & _Process2Win("dfsvc.exe") & @CRLF)
   WEnd

   ConsoleWrite('_Process2Win("dfsvc.exe"): ' & _Process2Win("dfsvc.exe") & @CRLF)

   WinWaitActive(_Process2Win("dfsvc.exe"), ControlGetText(_Process2Win("dfsvc.exe"), "", "[NAME:btnInstall]"))

   While ControlGetText(_Process2Win("dfsvc.exe"), "", "[NAME:btnInstall]") = ""
	  Sleep(250)
	  ConsoleWrite('ControlGetText("btnInstall"): ' & ControlGetText(_Process2Win("dfsvc.exe"), "", "[NAME:btnInstall]") & @CRLF & @CRLF)
   WEnd

   ControlClick(_Process2Win("dfsvc.exe"), ControlGetText(_Process2Win("dfsvc.exe"), "", "[NAME:btnInstall]"), "[NAME:btnInstall]")
EndFunc

Func OnAutoItExit()
   If ProcessExists("dfsvc.exe") Then
	  ProcessClose("dfsvc.exe")
   EndIf
   Exit
EndFunc

Func OnAutoItExitAdlib()
   ; Assign a static variable to hold the number of times the function is called.
   ; Local Static $iCount = 0
   ; $iCount += 1

   If Not ProcessExists("dfsvc.exe") Then
	  Exit
   EndIf

   ; ConsoleWrite("MyAdLibFunc called " & $iCount & " time(s)" & @CRLF)
EndFunc   ;==>OnAutoItExitAdlib

Func help()
    $msg = "ClickOnce-Unattended is a command line utility that silently install ClickOnce Applications." & @CRLF & _
            @CRLF & "Syntax:" & @CRLF & _
            @CRLF & "ClickOnce-Unattended   ""path""" & @CRLF & _
            @CRLF & "  path    I.E. C:\folder\sub-folder\setup.exe (use quotes if there are spaces)" & _
            @CRLF & "Example:" & _
            @CRLF & "ClickOnce-Unattended ""C:\test fol\setup.exe""" & @CRLF
    MsgBox(0, "ClickOnce-Unattended Help", $msg)
    Exit
 EndFunc  ;==>help

Func _FileOpenDialog()
    ; Create a constant variable in Local scope of the message to display in FileOpenDialog.
    ; Local Const $sMessage = "Hold down Ctrl or Shift to choose multiple files."
    Local Const $sMessage = "Select file."

    ; Display an open dialog to select a list of file(s).
    Local $sFileOpenDialog = FileOpenDialog($sMessage, @ScriptDir & "\", "Executables (*.exe)", $FD_FILEMUSTEXIST)
    If @error Then
        ; Display the error message.
        MsgBox($MB_SYSTEMMODAL, "", "No file was selected.")

        ; Change the working directory (@WorkingDir) back to the location of the script directory as FileOpenDialog sets it to the last accessed folder.
        FileChangeDir(@ScriptDir)

		Exit 1
    Else
        ; Change the working directory (@WorkingDir) back to the location of the script directory as FileOpenDialog sets it to the last accessed folder.
        FileChangeDir(@ScriptDir)

        ; Replace instances of "|" with @CRLF in the string returned by FileOpenDialog.
        $sFileOpenDialog = StringReplace($sFileOpenDialog, "|", @CRLF)

        ; Display the list of selected files.
        ; ConsoleWrite("You choose the following file:" & @CRLF & $sFileOpenDialog)
	 EndIf

	 Return $sFileOpenDialog
 EndFunc   ;==>Example
