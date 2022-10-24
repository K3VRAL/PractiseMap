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
				when "-h", "--hardrock"
					$hardrock = true
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