#!/bin/bash

curl -sSL https://raw.githubusercontent.com/pimterry/notes/latest-release/install.sh | bash
curl -sSL "https://raw.githubusercontent.com/pimterry/notes/latest-release/_notes" -o /usr/local/share/zsh/site-functions/_notes
