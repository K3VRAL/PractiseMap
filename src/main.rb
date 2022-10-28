#!/usr/bin/env ruby

$beatmap 	= ""
$output 	= ""
$time		= (Struct.new(:start, :end)).new
$beginning	= (Struct.new(:start, :amount)).new
$rng		= false
$hardrock	= false

require_relative "arguments"
require_relative "practise"

def main
	arguments
	puts "[#$beatmap][#$output][#{$time}][#{$beginning}][#$rng][#$hardrock]"
	practise
end

main