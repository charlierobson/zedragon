setlocal
set converter=%~dp0..\tools\converter\atasciiconvert.exe
call :convertFiles disk1
call :convertFiles disk2
call :convertFiles disk3
call :convertFiles disk4
endlocal
exit /b


:convertFiles
set src=original\%1
set dst=converted\%1
if not exist %dst% mkdir %dst%
for /f %%i in ('dir /b %src%\*') do %converter% %src%\%%i >%dst%\%%i
exit /b
