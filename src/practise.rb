require_relative("import")

class Practise
	@beatmap	= nil
	@time		= (Struct.new(:start, :end)).new
	@beginning	= nil
	@rng		= (Struct.new(:time, :position)).new
	@hardrock	= false
	@skip	= false

	class << self
		attr_accessor :beatmap, :output, :time, :beginning, :rng, :hardrock, :skip
	end

	def self.add_beginning(time, amount)
		if Practise.beginning.nil?
			Practise.beginning = Array.new
		end
		beg = (Struct.new(:time, :amount)).new
		beg[:time] = time
		beg[:amount] = amount
		Practise.beginning.push(beg)
	end

	def self.split_time(str)
		str_split = str.split(",", 0)
		if str_split.length != 2
			puts("Error: Time [#{t}] requires the start time and end time")
			exit(1)
		end
		for i in 0..str_split.length-1 do
			str_i = str_split[i].split(":", 0)
			if str_i.length == 3
				time_i = str_i.map(&:to_i)
				str_split[i] = (time_i[0] * 60000) + (time_i[1] * 1000) + time_i[2]
			else
				str_split[i] = str_split[i].to_i
			end
		end
		return str_split
	end
end

def practise_rename(map)
	type = !Practise.rng[:time].nil? || !Practise.rng[:position].nil? ? (Practise.hardrock ? "hrd" : "rng") : "nmd"
	version = "#{map[:metadata][:version]} - #{type} #{Practise.time[:start]}-#{Practise.time[:end]}"
	$output_global = LIBOSU.fopen("./#{map[:metadata][:artist]} - #{map[:metadata][:title]} (#{map[:metadata][:creator]}) [#{version}].osu", "w")
	if $output_global.null?
		puts("Error: Unable to create output file in current directory.")
		exit(1)
	end
	LIBOSU.ofb_metadata_setfromstring(map[:metadata], "Version:#{version}")
	temp, temp_num = map[:hit_objects], map[:num_ho]
	map[:hit_objects], map[:num_ho] = nil, 0
	LIBOSU.of_beatmap_tofile($output_global, map)
	map[:hit_objects], map[:num_ho] = temp, temp_num
end

def practise_rng(map)
	if Practise.rng[:time].nil? || Practise.rng[:position].nil?
		return
	end

	rng = LIBOSU::LegacyRandom.new
	LIBOSU.ou_legacyrandom_init(rng, LIBOSU.ooc_processor_RNGSEED)

	last_position = FFI::MemoryPointer.new(:pointer)
	last_start_time = FFI::MemoryPointer.new(:double)

	rng_num = 0

	map[:num_ho].times do | i |
		hit_object = LIBOSU::HitObject.new(map[:hit_objects].to_ptr + (i * LIBOSU::HitObject.size))
		if hit_object[:time] >= Practise.time[:start]
			next
		end

		object = LIBOSU::CatchHitObject.new
		case hit_object[:type]
		when :circle, :nc_circle
			LIBOSU.ooc_fruit_init(object, hit_object)
		when :slider, :nc_slider
			LIBOSU.ooc_juicestream_initwslidertp(object, map[:difficulty], map[:timing_points], map[:num_tp], hit_object);
			LIBOSU.ooc_juicestream_createnestedjuice(object);
		when :spinner, :nc_spinner
			LIBOSU.ooc_bananashower_init(object, hit_object)
			LIBOSU.ooc_bananashower_createnestedbananas(object)
		end

		old_rng = LIBOSU::LegacyRandom.new
		old_rng[:w] = rng[:w]
		old_rng[:x] = rng[:x]
		old_rng[:y] = rng[:y]
		old_rng[:z] = rng[:z]

		LIBOSU.ooc_processor_applypositionoffsetrng(object, 1, rng, Practise.hardrock, last_position, last_start_time)

		while !(old_rng[:w] == rng[:w] && old_rng[:x] == rng[:x] && old_rng[:y] == rng[:y] && old_rng[:z] == rng[:z])
			LIBOSU.ou_legacyrandom_nextuint(old_rng)
			rng_num += 1
		end
	end

	rng_div = (rng_num / (4 * 2)).to_i
	rng_mod = rng_num % (4 * 2)

	rng_div.times do | i |
		bs_ho = LIBOSU::HitObject.new
		bs_ho[:x] = 256
		bs_ho[:y] = 192
		bs_ho[:time] = Practise.rng[:time]
		bs_ho[:type] = :nc_spinner
		bs_ho[:hit_sound] = 0
		bs_ho[:ho][:spinner][:end_time] = Practise.rng[:time] + 1
		output = FFI::MemoryPointer.new(:pointer)
		LIBOSU.ofb_hitobject_tostring(output, bs_ho);
		LIBOSU.fprintf($output_global, output.read_pointer.read_string)
	end

        $beg_num = 0
	rng_mod.times do | i |
		if $js_faster_length.nil? || $js_faster_length == 1
			$js_faster_length = 1
		end
		js_ho = LIBOSU::HitObject.new
		js_ho[:x] = Practise.rng[:position]
		js_ho[:y] = 384
		js_ho[:time] = Practise.rng[:time]
		js_ho[:type] = :nc_slider
		js_ho[:hit_sound] = 0
		js_ho[:ho][:slider][:curve_type] = :slidertype_linear
		js_ho[:ho][:slider][:num_curve] = 1
		js_ho[:ho][:slider][:curves] = LIBOSU::HOSliderCurve.new
		js_ho[:ho][:slider][:curves][:x] = Practise.rng[:position]
		js_ho[:ho][:slider][:curves][:y] = 0
		js_ho[:ho][:slider][:slides] = 1
		js_ho[:ho][:slider][:length] = $js_faster_length

		loop do
			# For some reason, while looping, this gets GCed, so we have to reinitialise it ever time
			js_ho[:ho][:slider][:curves] = LIBOSU::HOSliderCurve.new
			js_ho[:ho][:slider][:curves][:x] = Practise.rng[:position]
			js_ho[:ho][:slider][:curves][:y] = 0

			js_obj = LIBOSU::CatchHitObject.new
			LIBOSU.ooc_juicestream_initwslidertp(js_obj, map[:difficulty], map[:timing_points], map[:num_tp], js_ho)
			LIBOSU.ooc_juicestream_createnestedjuice(js_obj)
			js_new = LIBOSU::JuiceStream.new(js_obj[:cho][:js])
			if js_new[:num_nested] == 3
				output = FFI::MemoryPointer.new(:pointer)
				LIBOSU.ofb_hitobject_tostring(output, js_ho);
				LIBOSU.fprintf($output_global, output.read_pointer.read_string)
                                $beg_num += 1
				break
			end
			$js_faster_length += 1
			js_ho[:ho][:slider][:length] = $js_faster_length
		end
	end
end

def practise_beginning(map)
	if Practise.beginning.nil?
		return
	end
	Practise.beginning.each do | i |
		if i[:amount] == 0
			ho = 0
			(map[:num_ho] - $beg_num).times do | j |
				map_ho = LIBOSU::HitObject.new(map[:hit_objects].to_ptr + (j * LIBOSU::HitObject.size))
				if map_ho[:time] >= Practise.time[:start] || ho == 200
					break
				else
					if map_ho[:type] == :slider || map_ho[:type] == :nc_slider
						js_cho = LIBOSU::CatchHitObject.new
						LIBOSU.ooc_juicestream_initwslidertp(js_cho, map[:difficulty], map[:timing_points], map[:num_tp], map_ho)
						LIBOSU.ooc_juicestream_createnestedjuice(js_cho)
						js = LIBOSU::JuiceStream.new(js_cho[:cho][:js])
						js[:num_nested].times do | k |
							object = LIBOSU::CatchHitObject.new(js[:nested].to_ptr + (k * LIBOSU::CatchHitObject.size))
							if ho == 200
								break
							elsif object[:type] == :catchhitobject_fruit || object[:type] == :catchhitobject_droplet
								ho += 1
							end
						end
					elsif map_ho[:type] == :circle || map_ho[:type] == :nc_circle
						ho += 1
					end
				end
			end

			hit_object = LIBOSU::HitObject.new
			hit_object[:x] = 256
			hit_object[:y] = 192
			hit_object[:time] = i[:time]
			hit_object[:type] = :circle
			hit_object[:hit_sound] = 0

			(ho-2).times do
				output = FFI::MemoryPointer.new(:pointer)
				LIBOSU.ofb_hitobject_tostring(output, hit_object);
				LIBOSU.fprintf($output_global, output.read_pointer.read_string)
			end

			2.times do
				hit_object[:type] = :nc_circle
				hit_object[:time] += 1
				output = FFI::MemoryPointer.new(:pointer)
				LIBOSU.ofb_hitobject_tostring(output, hit_object);
				LIBOSU.fprintf($output_global, output.read_pointer.read_string)
			end
		else
			i[:amount].times do
				hit_object = LIBOSU::HitObject.new
				hit_object[:x] = 256
				hit_object[:y] = 192
				hit_object[:time] = i[:time]
				hit_object[:type] = :nc_circle
				hit_object[:hit_sound] = 0
				output = FFI::MemoryPointer.new(:pointer)
				LIBOSU.ofb_hitobject_tostring(output, hit_object);
				LIBOSU.fprintf($output_global, output.read_pointer.read_string)
			end
		end
	end
end

def practise_time(map)
	map[:num_ho].times do | i |
		hit_object = LIBOSU::HitObject.new(map[:hit_objects].to_ptr + (i * LIBOSU::HitObject.size))
		if hit_object[:time] < Practise.time[:start] || hit_object[:time] > Practise.time[:end]
			next
		end

		output = FFI::MemoryPointer.new(:pointer)
		LIBOSU.ofb_hitobject_tostring(output, hit_object);
		LIBOSU.fprintf($output_global, output.read_pointer.read_string)
	end
end

def practise_main
	# Create the map to store all the data in
	map = LIBOSU::Beatmap.new
	LIBOSU.of_beatmap_init(map)
	if Practise.skip
		map[:timing_points] = LIBOSU.realloc(map[:timing_points], 1 * LIBOSU::TimingPoint.size)
		map[:num_tp] = 1
		LIBOSU.ofb_timingpoint_addfromstring(map[:timing_points], "-1,6,1,0,0,100,1,0")
	end
	LIBOSU.of_beatmap_set(map, Practise.beatmap)

	# Rename the map to tell the player what section of the map they are playing
	practise_rename(map)

	# Populate map with the `beginning` argument
	practise_beginning(map)
	
	# Process rng and populate map based on the rng
	practise_rng(map)

	# Record only the requested sections of the map
	practise_time(map)

	# Close output file
	LIBOSU.fclose($output_global)
end
