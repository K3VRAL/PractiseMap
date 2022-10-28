require_relative "import"

def practise
	if !system("pkg-config libosu")
		puts "Error: Unable to find `pkg-config` hasn't been installed or unable to locate `libosu`"
		exit 1
	end

	fp = LIBOSU.fopen($beatmap, "r")
	if fp.null?
		puts "Error: Beatmap input file [#$beatmap] was not found"
		exit 1
	end

	map = LIBOSU::Beatmap.new
	LIBOSU.of_beatmap_init(map)
	LIBOSU.of_beatmap_set(map, fp)

	pointer = map[:hit_objects].to_ptr
	array_ho = map[:num_ho].times.map { | i |
		LIBOSU::HitObject.new(pointer + (i * LIBOSU::HitObject.size))
	}

	store_objects = []
	for i in array_ho do
		if i[:time] >= $time.start && i[:time] <= $time.end
			puts "#{i[:x]}"
		end
	end
end