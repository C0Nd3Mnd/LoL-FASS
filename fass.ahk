;@Ahk2Exe-SetMainIcon fass.ico

AppVersion := "0.1"
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

  ;;; KILL ALL (DEAD) PROCESSES

  Process, Close, RiotClientCrashHandler.exe
  Process, Close, RiotClientServices.exe
  Process, Close, LeagueClient.exe
  Process, Close, LeagueClientUx.exe

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

  ExitApp, 0
