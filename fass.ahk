;;; CHOOSE ACCOUNT

FileRead, RawAccounts, accounts.txt

Accounts := StrSplit(Trim(RawAccounts, OmitChars = " `t`n"), "`n")

Random, ChosenIndex, 1, Accounts.MaxIndex()

ChosenAccount := Accounts[ChosenIndex]

AccountDetails := StrSplit(ChosenAccount, " ")

AccountUsername := AccountDetails[1]
AccountPassword := AccountDetails[2]

;;; KILL ALL (DEAD) PROCESSES

Process, Close, RiotClientCrashHandler.exe
Process, Close, RiotClientServices.exe
Process, Close, LeagueClient.exe
Process, Close, LeagueClientUx.exe

;;; RIOT CLIENT

Run, "D:\Games\Riot Games\Riot Client\RiotClientServices.exe" --launch-product=league_of_legends --launch-patchline=live

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
