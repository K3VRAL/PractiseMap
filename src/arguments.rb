require "optparse"

require_relative "practise"

def arguments_main
	ARGV << "-h" if ARGV.empty?

	OptionParser.new do | i |
		i.banner = "usage: pracmap [options]"

		i.on("-b", "--beatmap file", "inputs the file to be read and manipulated") do | b |
			if !Practise.beatmap.nil? && !Practise.beatmap.null?
				puts("Error: Input file has already been inputted despite attempting to input [#{b}]")
				exit(1)
			end
			fp = LIBOSU.fopen(b, "r")
			if fp.null?
				puts("Error: Input file [#{b}] has not been found")
				exit(1)
			end
			Practise.beatmap = fp
		end
		
		i.on("-o", "--output [file]", "outputs the manipulated file") do | o |
			if !Practise.output.nil? && !Practise.output.null?
				puts("Error: Output file has already been inputted despite attempting to input [#{o}]")
				exit(1)
			end
			fp = LIBOSU.fopen(o, "w")
			if fp.null?
				puts("Error: Output file [#{o}] is not possible")
				exit(1)
			end
			Practise.output = fp
		end

		i.on("-t", "--time start,end", "start and end time to start including the objects") do | t |
			str_split = t.split(",", 0)
			if str_split.length() != 2
				puts("Error: Time [#{t}] requires the start time and end time")
				exit(1)
			end
			Practise.time[:start] = str_split[0].to_i
			Practise.time[:end] = str_split[1].to_i
		end

		i.on("-g", "--beginning [time,amount]", "gives the time and amount of objects to be placed before the beatmap starts") do | g |
			str_split = g.split(",", 0)
			if str_split.length() != 2
				puts("Error: Beginning [#{t}] requires the time and the amount")
				exit(1)
			end
			Practise.add_beginning(str_split[0].to_i, str_split[1].to_i)
		end

		i.on("-r", "--rng [time,position]", "keeps track of the rng elements of the map and outputs it to the beginning of the map") do | r |
			puts("#{r}")
			str_split = r.split(",", 0)
			if str_split.length() != 2
				puts("Error: RNG [#{r}] requires the time and the position")
				exit(1)
			end
			Practise.rng[:time] = str_split[0].to_i
			Practise.rng[:position] = str_split[1].to_i
		end

		i.on("-d", "--hardrock", "keeps track of the rng elements given that hardrock is enabled; relies on `-r` to be used") do
			Practise.hardrock = true
		end

		i.on("-h", "--help", "gives this help message") do
			puts(i)
			exit(1)
		end
	end.parse!
end