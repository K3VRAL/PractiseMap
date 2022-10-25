def arguments
	args = ""
	ARGV.each do | i |
		if args == ""
			case i
				when "-b", "--beatmap"
					args = "b"
				when "-o", "--output"
					args = "o"
				when "-s", "--start"
					args = "s"
				when "-e", "--end"
					args = "e"
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
					puts "\t-s, --start [time]\tstart time to start including the objects"
					puts "\t-e, --end [time]\tend time to stop including the objects"
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
				when "s"
					$start_time = i.to_i
				when "e"
					$end_time = i.to_i
			end
			args = ""
		end
	end
end