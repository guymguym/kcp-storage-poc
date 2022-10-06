#!/bin/sh
go mod tidy
go mod vendor
echo '*' > vendor/.gitignore
IGNORE_GO_VERSION=1 make
