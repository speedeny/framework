::���汾ר��
echo off
chcp 936

pushd "%~dp0"

::---------------------------------------------------
::�Զ�����Lua��Project�ļ�
::---------------------------------------------------
ProjectLuaGenerator.exe ..\client\Data\LuaScript\Core
ProjectLuaGenerator.exe ..\client\Data\LuaScript\Define
ProjectLuaGenerator.exe ..\client\Data\LuaScript\Interface
ProjectLuaGenerator.exe ..\client\Data\LuaScript\Lib
ProjectLuaGenerator.exe ..\client\Data\LuaScript\Logic
popd
pause
