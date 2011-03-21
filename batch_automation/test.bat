set /p continue= Build deploy all no clean min merge? Y/N :
if not %continue% == Y goto skipped

echo not skipped

:skipped

pause