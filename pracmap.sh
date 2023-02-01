#!/bin/sh

for arg in "$@"; do
	if [ "install" = "$arg" ]; then
		mkdir -p /usr/local/bin/pracmap/
		cp ./src/* /usr/local/bin/pracmap/
		chmod 755 /usr/local/bin/pracmap/*
		ln -s /usr/local/bin/pracmap/main.rb /usr/bin/pracmap
	fi
	if [ "uninstall" = "$arg" ]; then
		unlink /usr/bin/pracmap
		rm -rf /usr/local/bin/pracmap
	fi
done