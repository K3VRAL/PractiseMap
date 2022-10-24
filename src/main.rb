$beatmap 	= ""
$output 	= ""
$start_time	= 0
$end_time	= 0
$rng		= false
$hardrock	= false

require_relative "arguments"

def main
	arguments
	puts "[#$beatmap][#$output][#$start_time][#$end_time][#$rng][#$hardrock]"
end

main