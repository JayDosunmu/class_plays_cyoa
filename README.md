# Class Plays "Choose Your Own Adventure" Game

This is an extra credit project for GSU CSCI 3320, System-Level Programming

Creators:
- Jay Dosunmu
- Jeffrey Bruggeman

### How to Run it:
1. Compile server.c and client.c
2. If running locally, start the `server`, `client`, and `gameMulti.sh`:
```
Shell 1
~# ./server.o
```
```
Shell 2
~# ./client.o
```
```
Shell 3
~# ./gameMulti.sh
```

This can also be played remotely, as long as the correct hostname is provided as an argument to `client`, e.g.
```
~# ./client.o tcp://0.tcp.ngrok.io:15991
```