#!/bin/bash

# sudo apt-get install pandoc texlive texlive-xetex texlive-fonts-recommended

pandoc index.md antispam.md auth.md composer.md extra-features.md install.md manage-folders.md profile.md pro-tips.md quota.md read.md search.md  -o output.pdf --pdf-engine=xelatex
