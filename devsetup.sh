#!/bin/sh

if command -v sourcery; then
  pushd ZwaaiLogic
  sourcery
  popd

  pushd ZwaaiLogicTests
  sourcery
  popd
else
  echo 'warning: Sourcery not installed, download from https://github.com/krzysztofzablocki/Sourcery'
fi

