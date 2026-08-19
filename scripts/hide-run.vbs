' hide-run.vbs - run one command line with no visible window.
' Usage: wscript.exe "C:\Users\Polar\.dsh\hide-run.vbs" "cmd /c ..."
Set sh = CreateObject("WScript.Shell")
Dim args
ReDim args(WScript.Arguments.Count - 1)
Dim i
For i = 0 To WScript.Arguments.Count - 1
  args(i) = WScript.Arguments(i)
Next
sh.Run Join(args, " "), 0, False