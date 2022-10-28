require "optparse"

def arguments
	OptionParser.new do | i |
		i.on("-b", "--beatmap [file]", "inputs the file to be read and manipulated") { | b |
			$beatmap = b
		}
		i.on("-o", "--output [file]", "outputs the manipulated file") { | o |
			$output = o
		}
		i.on("-t", "--time [start,end]", "start and end time to start including the objects") { | t |
			str_split = t.split(',', 0)
			$time.start = str_split[0].to_i
			$time.end = str_split[1].to_i
		}
		i.on("-g", "--beginning [start,amount]", "gives the time and amount of objects to be placed before the beatmap starts") { | g |
			str_split = g.split(',', 0)
			$beginning.start = str_split[0].to_i
			$beginning.amount = str_split[1].to_i
		}
		i.on("-r", "--rng", "keeps track of the rng elements of the map and outputs it to the beginning of the map") {
			$rng = true
		}
		i.on("-d", "--hardrock", "keeps track of the rng elements given that hardrock is enabled") {
			$hardrock = true
		}
	end.parse!
end