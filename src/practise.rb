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
	# if $beginning.time != nil
	# 	store_beginning = []
	# end
	for i in array_ho do
		if i[:time] >= $time.start && i[:time] <= $time.end
			store_objects.push(i)
		end
		# if store_beginning != nil i[:time] < $beginning.time && store_beginning.size < $beginning.amount do
		# 	store_beginning.push(i)
		# end
	end

	# if store_beginning != nil
	# 	while store_beginning.size < $beginning.amount do
	# 		hit_object = LIBOSU::HitObject.new
	# 		hit_object[:x] = 256
	# 		hit_object[:y] = 192
	# 		hit_object[:time] = $beginning.time
	# 		hit_object[:type] = :nc_circle
	# 		store_beginning.push(hit_object)
	# 	end
	# end

	LIBOSU.oos_hitobject_freebulk(map[:hit_objects], map[:num_ho])
	map[:num_ho] = store_objects.size
	map[:hit_objects] = FFI::MemoryPointer.new(LIBOSU::HitObject.size, map[:num_ho])
	puts "#{map[:hit_objects].values}"
end