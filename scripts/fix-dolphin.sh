#!/bin/bash

# make kitty default open terminal
kwriteconfig6 --file kdeglobals --group General --key TerminalApplication /usr/bin/kitty
