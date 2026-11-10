@echo off
rem Prueft den Stand mit dem lokalen Flutter und schreibt das Ergebnis nach pruefung.txt
cd /d "%~dp0.."
echo Pruefung laeuft, bitte warten ...
echo === flutter --version > pruefung.txt
call flutter --version >> pruefung.txt 2>&1
echo === flutter pub get >> pruefung.txt
call flutter pub get >> pruefung.txt 2>&1
echo === flutter analyze >> pruefung.txt
call flutter analyze --no-fatal-infos --no-fatal-warnings >> pruefung.txt 2>&1
echo === flutter test >> pruefung.txt
call flutter test >> pruefung.txt 2>&1
echo === flutter build web >> pruefung.txt
call flutter build web --release --base-href / >> pruefung.txt 2>&1
echo === FERTIG >> pruefung.txt
echo Fertig. Ergebnis steht in pruefung.txt
pause
