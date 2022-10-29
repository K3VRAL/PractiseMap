require "optparse"

def arguments
	OptionParser.new do | i |
		i.banner = "usage: pracmap [options]"

		i.on("-b", "--beatmap file", "inputs the file to be read and manipulated") do | b |
			$beatmap = b
		end
		
		i.on("-o", "--output [file]", "outputs the manipulated file") do | o |
			$output = o
		end

		i.on("-t", "--time start,end", "start and end time to start including the objects") do | t |
			str_split = t.split(',', 0)
			$time.start = str_split[0].to_i
			$time.end = str_split[1].to_i
		end

		i.on("-g", "--beginning [time,amount]", "gives the time and amount of objects to be placed before the beatmap starts") do | g |
			str_split = g.split(',', 0)
			$beginning.time = str_split[0].to_i
			$beginning.amount = str_split[1].to_i
		end

		i.on("-r", "--rng", "keeps track of the rng elements of the map and outputs it to the beginning of the map") do
			$rng = true
		end

		i.on("-d", "--hardrock", "keeps track of the rng elements given that hardrock is enabled; relies on `-r` to be used") do
			$hardrock = true
		end

		i.on("-h", "--help", "gives this help message") do
			puts i
			exit
		end
	end.parse!
end