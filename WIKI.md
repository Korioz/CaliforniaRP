# CaliforniaRP - Wiki

## Rajouter une ressource de farm
https://youtu.be/yRxAjr4JNOA

## Ajouter un job gang
https://youtu.be/pOMON4j-8xk

## Résoudre le problème de spawn
Si vous avez ce problème c'est que vous n'êtes pas en OneSync ce qui est obligatoire.

Pour ce faire il vous faut soit le faire depuis les paramètres du Panel `txAdmin` soit avoir un start.bat possédant `+set onesync on` en arguments de démarrage comme ci-dessous :
```bat
@echo off
cd CHEMIN_DU_RESOURCES
.\FXServer.exe +exec server.cfg +set onesync on
pause
```
