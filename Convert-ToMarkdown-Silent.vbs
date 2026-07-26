Set WshShell = CreateObject("WScript.Shell")
Set objArgs = WScript.Arguments

If objArgs.Count > 0 Then
    filePath = objArgs(0)
    command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File ""E:\projects\Convert-ToMarkdown.ps1"" """ & filePath & """"
    WshShell.Run command, 0, False
End If
