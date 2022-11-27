@echo off
color 0a
cd ..
@echo on
echo BUILDING GAME
haxelib run lime test android -release
pause