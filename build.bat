@echo off
rem TODO:
rem C++ compilation flags.
rem zig build-exe --help
rem -fno-compiler-rt -fno-sanitize=undefined -fPIE -fPIC -mcmodel=
setlocal
if "%~1" equ "" (
    echo ERROR: Expected 1 command.
    echo.
    call :usage 1
) else if not "%~2" equ "" (
    echo ERROR: Expected 1 command.
    echo.
    call :usage 1
)
set base_cmd=zig build-exe .\src\main.zig -I.\src\ -I.\lib\ --name speedo --color on -femit-bin=".\bin\speedo.exe" -fno-emit-implib --cache-dir .\bin\.cache\ -freference-trace=16 -ftime-report -fstack-report
set release_cmd=%base_cmd% -OReleaseFast -fllvm -flibllvm -fclang -flld -flto -fformatted-panics -fstrip -fno-stack-check -fno-stack-protector -fno-unwind-tables
if "%1" equ "release" (
    %release_cmd%
    strip -R.comment .\bin\speedo.exe
    .\bin\speedo.exe
) else if "%1" equ "debug" (
    %base_cmd% -ODebug -fformatted-panics -fsanitize-c -fsanitize-thread -ferror-tracing
    .\bin\speedo.exe
) else if "%1" equ "profile" (
    %release_cmd% .\lib\tracy\public\TracyClient.cpp -DTRACY_ENABLE=1 -lc -lc++ -ldbghelp -lws2_32
    strace -tw .\bin\speedo.exe
) else if "%1" equ "help" (
    call :usage 0
) else (
    echo ERROR: Unexpected command '%1'.
    echo.
    call :usage 1
)
exit /b 0
:usage
echo USAGE:
echo    build.bat [command]
echo.
echo COMMANDS:
echo    help       Print help and exit.
echo    release    Build Speedo in release mode.
echo    debug      Build Speedo in debug mode.
echo    profile    Build Speedo in profiling mode and profile it with Strace and Tracy.
exit /b %1
endlocal
