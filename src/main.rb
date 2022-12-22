#!/usr/bin/env ruby

require_relative("arguments")
require_relative("practise")

def main
	if !system("pkg-config libosu")
		puts("Error: Unable to find `pkg-config` hasn't been installed or was unable to be located `libosu`")
		exit(1)
	end

	arguments_main
	
	practise_main

	if !Practise.beatmap.nil?
		LIBOSU.fclose(Practise.beatmap)
	end

	if !Practise.output.nil?
		LIBOSU.fclose(Practise.output)
	end
end

main