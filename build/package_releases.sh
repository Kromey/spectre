#!/bin/bash

linux=spectre-linux-x86_64.tgz
windows=spectre-win64.zip

# Clean up first
rm $linux $windows

# Package for Windows
zip $windows *.exe *.pck

# Package for Linux
tar -cjf $linux *.x86_64 *.pck

