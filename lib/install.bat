@echo off
set tracy_version=v0.10
git submodule add https://github.com/wolfpld/tracy.git
cd .\tracy\
git reset --hard %tracy_version%
cd ..\
