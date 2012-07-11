@echo off
for %%F in (%0) do set dirname=%%~dpF
echo "custom phantomjs called" > %dirname%custom_phantomjs_called
phantomjs  %* 