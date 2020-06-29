#!/bin/sh

if command -v sourcery; then
  cd ZwaaiLogic
  sourcery
else
  echo 'warning: Sourcery not installed, download from https://github.com/krzysztofzablocki/Sourcery'
fi

