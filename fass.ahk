;@Ahk2Exe-SetMainIcon fass.ico

global AppVersion := "0.3.0"
global IniPath := "settings.ini"

;;; CHOOSE ACCOUNT

; Reads the account list from the settings file and generates a ListBox
; compatible string with account usernames.
GetAccountList() {
  IniRead, UseAlias, %IniPath%, General, UseAlias

  if (UseAlias == "true") {
    IniRead, RawAccounts, %IniPath%, Alias
  } else {
    IniRead, RawAccounts, %IniPath%, Accounts
  }

  Accounts := StrSplit(Trim(RawAccounts, OmitChars = " `t`n"), "`n")

  Listing :=

  for Index, Account in Accounts {
    Username := StrSplit(Account, "=")[1]
    Listing = %Listing%%Username%

    if (Index != Accounts.MaxIndex()) {
      Listing = %Listing%|
    }
  }

  return Listing
}

Gui, Main:New,, Choose Account
Listing := GetAccountList()
Gui, Main:Add, ListBox, r10 w240 vAccountUsername gLaunchViaList, %Listing%
Gui, Main:Add, Button, w240 gAddAccount, Add Account
Gui, Main:Add, Button, w240 gRemoveAccount, Remove Account
Gui, Main:Add, Button, w240 gExitButton, Exit
Gui, Main:Add, StatusBar,, LoL-FASS v%AppVersion% with ♥ by C0Nd3Mnd
Gui, Main:Show
return

GuiEscape:
GuiClose:
ExitButton:
  ExitApp, 0

AddAccount:
  Gui, AddAccount:New,, Add Account
  Gui, AddAccount:Add, Text,, Username
  Gui, AddAccount:Add, Edit, w240 vNewUsername
  Gui, AddAccount:Add, Text,, Password
  Gui, AddAccount:Add, Edit, Password w240 vNewPassword
  Gui, AddAccount:Add, Button, w240 gConfirmAddAccount, Add
  Gui, AddAccount:Add, Button, w240 gCancel, Cancel
  Gui, AddAccount:Add, Text, cGray w240, Note that if you enter a username that already exists, its password will be changed instead.
  Gui, AddAccount:Show
  return

ReloadAccountList() {
  Listing := GetAccountList()
  GuiControl, Main:, AccountUsername, |%Listing%
}

ConfirmAddAccount:
  Gui, AddAccount:Submit, NoHide
  if (NewUsername == "") {
    MsgBox, Username cannot be empty!
    return
  }

  if (NewPassword == "") {
    MsgBox, Password cannot be empty!
    return
  }

  IniWrite, %NewPassword%, %IniPath%, Accounts, %NewUsername%
  Gui, AddAccount:Hide
  ReloadAccountList()
  return

RemoveAccount(AccountUsername) {
  IniDelete, %IniPath%, Accounts, %AccountUsername%
  ReloadAccountList()
}

RemoveAccount:
  Gui, Main:Submit, NoHide
  MsgBox, 4, Remove account?, Remove account "%AccountUsername%"?
  IfMsgBox Yes
    RemoveAccount(AccountUsername)
  return

LaunchViaList:
  if (A_GuiEvent == "DoubleClick") {
    Gui, Main:Submit
    Goto, Main
  }
  return

Main:
  IniRead, UseAlias, %IniPath%, General, UseAlias

  if (UseAlias == "true") {
    IniRead, AccountUsername, %IniPath%, Alias, %AccountUsername%
  }

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

  WinGetPos, ,, LauncherWidth, LauncherHeight, Riot Client Main

  Sleep, 1000

  ; Username
  UsernameInputX := LauncherWidth * 0.13
  UsernameInputY := LauncherHeight * 0.3
  ControlClick, x%UsernameInputX% y%UsernameInputY%, Riot Client Main
  Send, {Text}%AccountUsername%

  ; Password
  Send, {Tab}
  Send, {Text}%AccountPassword%

  ; Login button
  Send, {Enter}

  ; Show skip window to exit early.
  SkipPosX := A_ScreenWidth - 300
  SkipPosY := A_ScreenHeight - 140
  Gui, Skip:New,, Update Skip
  Gui, Skip:Add, Button, w240 gExit, Exit Early (Update Skip)
  Gui, Skip:Show, x%SkipPosX% y%SkipPosY%

  ; Press play if the window still exists (sometimes it doesn't launch
  ; automatically).
  Loop {
    Sleep, 5000

    if WinExist("Riot Client Main") {
      PlayButtonX := LauncherWidth * 0.1302
      PlayButtonY := LauncherHeight * 0.3472

      ControlClick, x%PlayButtonX% y%PlayButtonY%, Riot Client Main
    } else {
      break
    }
  }

Exit:
  ExitApp, 0
