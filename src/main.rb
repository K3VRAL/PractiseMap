#!/usr/bin/env ruby

require_relative("arguments")
require_relative("practise")

def main
	arguments_main
	
	if !Practise.beatmap.nil? && !Practise.time[:start].nil? && !Practise.time[:end].nil?
		practise_main
	else
		puts("Error: Either the Beatmap or the Time was not set.")
	end

	if !Practise.beatmap.nil?
		LIBOSU.fclose(Practise.beatmap)
	end
end

main