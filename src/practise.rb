require_relative "import"

def practise
	was_good = system("pkg-config libosu")
	if !was_good
		puts "Error: Unable to find `pkg-config` hasn't been installed or unable to locate `libosu`"
		exit 1
	end

	# TODO
	fp = LIBOSU.fopen($beatmap, "r")
	if fp.null?
		puts "Error: Beatmap input file [#$beatmap] was not found"
		exit 1
	end

	map = Beatmap.new
	LIBOSU.of_beatmap_init(map)
	LIBOSU.of_beatmap_set(map, fp)
	
	for i in 1..map[:num_ho] do
		puts i
	end

	LIBOSU.fclose(fp)
	LIBOSU.of_beatmap_free(map)
end