#!/usr/bin/env ruby

require_relative("arguments")
require_relative("practise")

def main
	arguments_main

	if !system("pkg-config libosu")
		puts("Error: Unable to find `pkg-config` hasn't been installed or was unable to be located `libosu`")
		exit(1)
	end

	practise_main
end

main