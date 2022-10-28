def arguments
	args = ""
	ARGV.each do | i |
		if args == ""
			case i
				when "-b", "--beatmap"
					args = "b"
				when "-o", "--output"
					args = "o"
				when "-t", "--time"
					args = "t"
				when "-g", "--beginning"
					args = "g"
				when "-r", "--rng"
					$rng = true
				when "-d", "--hardrock"
					$hardrock = true
				when "-h", "--hardrock"
					puts "PractiseMap"
					puts ""
					puts "usage:"
					puts "\tpracmap [arguments]"
					puts ""
					puts "arguments:"
					puts "\t-b, --beatmap [file]\tinputs the file to be read and manipulated"
					puts "\t-o, --output [file]\toutputs the manipulated file"
					puts "\t-t, --time [start,end]\tstart and end time to start including the objects"
					puts "\t-g, --beg [time,amount]\tgives the time and amount of objects to be placed before the beatmap starts"
					puts "\t-r, --rng\tkeeps track of the rng elements of the map and outputs it to the beginning of the map"
					puts "\t-d, --hardrock\tkeeps track of the rng elements given that hardrock is enabled"
					puts "\t-h, --help\tgives this help message"
			end
		else
			case args
				when "b"
					$beatmap = i
				when "o"
					$output = i
				when "t"
					str_split = i.split(',', 0)
					$time.start = str_split[0].to_i
					$time.end = str_split[1].to_i
				when "g"
					str_split = i.split(',', 0)
					$beginning.start = str_split[0].to_i
					$beginning.amount = str_split[1].to_i
			end
			args = ""
		end
	end
end