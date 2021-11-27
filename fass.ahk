﻿;@Ahk2Exe-SetMainIcon fass.ico

AppVersion := "0.1.1"
IniPath := "settings.ini"

;;; CHOOSE ACCOUNT

IniRead, RawAccounts, %IniPath%, Accounts

Accounts := StrSplit(Trim(RawAccounts, OmitChars = " `t`n"), "`n")

Listing :=

for Index, Account in Accounts {
  Username := StrSplit(Account, "=")[1]
  Listing = %Listing%%Username%

  if (Index != Accounts.MaxIndex()) {
    Listing = %Listing%|
  }
}

Gui, New,, Choose Account
Gui, Add, ListBox, r10 w240 vAccountUsername gLaunchViaList, %Listing%
Gui, Add, Button, w240 gCancelButton, Cancel
Gui, Add, StatusBar,, LoL-FASS v%AppVersion% with ♥ by C0Nd3Mnd
Gui, Show
return

GuiEscape:
GuiClose:
CancelButton:
  ExitApp, 0

LaunchViaList:
  if (A_GuiEvent == "DoubleClick") {
    Gui, Submit
    Goto, Main
  }
  return

Main:
  IniRead, AccountPassword, %IniPath%, Accounts, %AccountUsername%

  if WinExist("ahk_exe LeagueClientUx.exe") {
    WinGetPos, ,, ClientWidth, ClientHeight, ahk_exe LeagueClientUx.exe

    CloseButtonX := ClientWidth * 0.9849
    CloseButtonY := ClientHeight * 0.0203
    ; Can be an exit button...
    ExitButtonX := ClientWidth * 0.4557
    ExitButtonY := ClientHeight * 0.5574
    ; ...or a Yes button.
    YesButtonX := ClientWidth * 0.4739
    YesButtonY := ClientHeight * 0.6018

    ControlClick, x%CloseButtonX% y%CloseButtonY%, ahk_exe LeagueClientUx.exe

    ; Delay for a bit since the client can be slow to open the window sometimes.
    Sleep, 500

    ; Click the Yes button first because if the Exit button is the correct one
    ; the other click sometimes still goes through before the client exits
    ; potentially resulting in a click on the start page of the client which
    ; opens up a website in a browser.
    ControlClick, x%YesButtonX% y%YesButtonY%, ahk_exe LeagueClientUx.exe
    ControlClick, x%ExitButtonX% y%ExitButtonY%, ahk_exe LeagueClientUx.exe

    ;; Delay a bit so the dodge works more reliably.
    Sleep, 1000
  }

  ;;; KILL ALL (DEAD) PROCESSES

  Process, Close, RiotClientCrashHandler.exe
  Process, Close, RiotClientServices.exe
  Process, Close, LeagueClient.exe
  Process, Close, LeagueClientUx.exe

  Process, WaitClose, RiotClientCrashHandler.exe
  Process, WaitClose, RiotClientServices.exe
  Process, WaitClose, LeagueClient.exe
  Process, WaitClose, LeagueClientUx.exe

  ;;; RIOT CLIENT

  IniRead, RiotPath, %IniPath%, General, RiotPath

  Run, "%RiotPath%\Riot Client\RiotClientServices.exe" --launch-product=league_of_legends --launch-patchline=live

  Loop {
    if WinExist("Riot Client Main") {
      Sleep, 1000
      Break
    }
    Sleep, 1000
  }

  ControlClick, x80 y80, Riot Client Main

  ; Username
  Send, {Tab}
  Send, {Text}%AccountUsername%

  ; Password
  Send, {Tab}
  Send, {Text}%AccountPassword%

  ; Login button
  Send, {Enter}

  ; Press play if the window still exists (sometimes it doesn't launch
  ; automatically).
  Loop {
    Sleep, 5000

    if WinExist("Riot Client Main") {
      WinGetPos, ,, LauncherWidth, LauncherHeight, Riot Client Main

      PlayButtonX := LauncherWidth * 0.125
      PlayButtonY := LauncherHeight * 0.9352

      ControlClick, x%PlayButtonX% y%PlayButtonY%, Riot Client Main
    } else {
      break
    }
  }

  ExitApp, 0
