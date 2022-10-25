$beatmap 	= ""
$output 	= ""
$start_time	= 0
$end_time	= 0
$rng		= false
$hardrock	= false

require_relative "arguments"
require_relative "practise"

def main
	arguments
	puts "[#$beatmap][#$output][#$start_time][#$end_time][#$rng][#$hardrock]"
	practise
end

main