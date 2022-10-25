require_relative "import"

def practise
	was_good = system("pkg-config libosu")
	if !was_good
		puts "Unable to find `pkg-config` hasn't been installed or unable to `libosu`"
		exit 1
	end

	beatmap = Beatmap.new
	LIBOSU.of_beatmap_init(beatmap)
	
	LIBOSU.of_beatmap_free(beatmap)
end