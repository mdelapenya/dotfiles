#!/usr/bin/env bash

BASEDIR=$(dirname "$0")

while read ext; do
    code --install-extension $ext
done <${BASEDIR}/vscode-ext.txt
