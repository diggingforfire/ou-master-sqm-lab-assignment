:: rerun actual script (see below) with elevated rights
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )

:: actual script (run junit)
@echo off
> result.txt (
	java -classpath "C:\Dev\smallsql0.21_src\target\classes;C:\Program Files\eclipse\plugins\org.junit_4.13.0.v20200204-1500.jar;C:\Program Files\eclipse\plugins\org.hamcrest.core_1.3.0.v20180420-1519.jar;C:\Dev\jdbc.jar;C:\Users\Robbie\.eclipse\org.eclipse.platform_4.16.0_1709980481_win32_win32_x86_64\configuration\org.eclipse.osgi\229\0\.cp;C:\Users\Robbie\.eclipse\org.eclipse.platform_4.16.0_1709980481_win32_win32_x86_64\configuration\org.eclipse.osgi\228\0\.cp" org.junit.runner.JUnitCore smallsql.junit.AllTests
)