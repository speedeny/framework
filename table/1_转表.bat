::出版本专用
echo off
chcp 936

pushd "%~dp0"

::---------------------------------------------------
::自动生成Lua的Project文件
::---------------------------------------------------
ProjectLuaGenerator.exe ..\client\Data\LuaScript\Core
ProjectLuaGenerator.exe ..\client\Data\LuaScript\Define
ProjectLuaGenerator.exe ..\client\Data\LuaScript\Interface
ProjectLuaGenerator.exe ..\client\Data\LuaScript\Lib
ProjectLuaGenerator.exe ..\client\Data\LuaScript\Logic
popd
pause
