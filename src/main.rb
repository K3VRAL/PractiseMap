#!/usr/bin/env ruby

$beatmap 	= ""
$output 	= nil
$time		= (Struct.new(:start, :end)).new
$beginning	= (Struct.new(:time, :amount)).new
$rng		= false
$hardrock	= false

require_relative "arguments"
require_relative "practise"

def main
	arguments
	puts "[#$beatmap][#$output][#$time}][#$beginning}][#$rng][#$hardrock]"
	practise
end

main