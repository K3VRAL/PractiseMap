require_relative "import"

class Practise
	@beatmap	= nil
	@output		= nil
	@time		= (Struct.new(:start, :end)).new
	@beginning	= Array.new
	@rng		= (Struct.new(:time, :position)).new
	@hardrock	= false

	class << self
		attr_accessor :beatmap, :output, :time, :beginning, :rng, :hardrock
	end

	def	add_beginning(time, amount)
		beg = (Struct.new(:time, :amount)).new
		beg[:time] = time
		beg[:amount] = amount
		Practise.beginning.push(beg)
	end
end

def practise_rename(map)
	LIBOSU.ofb_metadata_setfromstring(map[:metadata], "Version:#{Practise.time[:start]}-#{Practise.time[:end]}")
	temp = map[:hit_objects]
	temp_num = map[:num_ho]
	map[:hit_objects] = nil
	map[:num_ho] = 0
	LIBOSU.of_beatmap_tofile(Practise.output, map)
	map[:hit_objects] = temp
	map[:num_ho] = temp_num
end

def practise_beginning(map)
	for i in Practise.beginning
		for j in 1..i[:amount]
			hit_object = LIBOSU::HitObject.new
			hit_object[:x] = 256
			hit_object[:y] = 192
			hit_object[:time] = i[:time]
			hit_object[:type] = :nc_circle
			hit_object[:hit_sound] = 0
			output = FFI::MemoryPointer.new(:pointer, 1)
			LIBOSU.ofb_hitobject_tostring(output, hit_object);
			LIBOSU.fprintf(Practise.output, output.read_pointer.read_string)
		end
	end
end

def practise_rng_processor(map)
	objects_arr = Array.new
	map[:num_ho].times do | i |
		hit_object = LIBOSU::HitObject.new(map[:hit_objects].to_ptr + (i * LIBOSU::HitObject.size))
		if hit_object[:time] >= Practise.time[:start]
			break
		end
		object = LIBOSU::CatchHitObject.new
		case hit_object[:type]
		when :circle, :nc_circle
			LIBOSU.ooc_fruit_init(object, hit_object)
		when :slider, :nc_slider
			LIBOSU.ooc_juicestream_initwslidertp(object, map[:difficulty], map[:timing_points], map[:num_tp], hit_object)
			LIBOSU.ooc_juicestream_createnestedjuice(object)
		when :spinner, :nc_spinner
			LIBOSU.ooc_bananashower_init(object, hit_object)
			LIBOSU.ooc_bananashower_createnestedbananas(object)
		end
		objects_arr.push(object)
	end

	# TODO error here, convert ruby array to pointer array of struct
	objects = FFI::MemoryPointer.new(LIBOSU::CatchHitObject, objects_arr.size)
	objects_arr.length.times do | i |
		objects.put(LIBOSU::CatchHitObject, i, objects_arr[i])
	end

	rng = LIBOSU::LegacyRandom.new
	LIBOSU.ou_legacyrandom_init(rng, LIBOSU.ooc_processor_RNGSEED)
	LIBOSU.ooc_processor_applypositionoffsetrng(objects, objects_arr.size, rng, Practise.hardrock)

	return objects, objects_arr.size
end

def practise_rng(object)
	case object[:type]
	when :catchhitobject_fruit
		# TODO Make sure this is correct
		if $js_faster_length.nil? || $js_faster_length == 1
			$js_faster_length = 1
		end
		js_ho = LIBOSU::HitObject.new
		js_ho[:x] = Practise.rng[:position]
		js_ho[:y] = 384
		js_ho[:time] = Practise.rng[:time]
		js_ho[:type] = :nc_slider
		js_ho[:hit_sound] = 1
		js_ho[:ho][:slider][:curve_type] = :slidertype_linear
		js_ho[:ho][:slider][:curves] = LIBOSU::HOSliderCurve.new
		js_ho[:ho][:slider][:curves][:x] = Practise.rng[:position]
		js_ho[:ho][:slider][:curves][:y] = 0
		js_ho[:ho][:slider][:num_curve] = 1
		js_ho[:ho][:slider][:slides] = 1
		js_ho[:ho][:slider][:length] = $js_faster_length
		loop do
			js_obj = LIBOSU::CatchHitObject.new
			LIBOSU.ooc_juicestream_initwslidertp(js_obj, map[:difficulty], map[:timing_points], map[:num_tp], js_ho)
			LIBOSU.ooc_juicestream_createnestedjuice(js_obj)
			js_new = LIBOSU::JuiceStream.new(js_obj[:cho][:js])
			if js_new[:num_nested] == 4
				output = FFI::MemoryPointer.new(:pointer)
				LIBOSU.ofb_hitobject_tostring(output, js_ho)
				LIBOSU.fprintf(Practise.output, output.read_pointer.read_string)
				break
			end
			$js_faster_length += 1
			js_ho[:ho][:slider][:length] += 1
		end
	# when :catchhitobject_juicestream
	# 	# TODO
	# 	js = LIBOSU::JuiceStream.new(object[:cho][:js])
	# 	print("[j]")
	# 	js[:num_nested].times do | i |
	# 		nested_object = LIBOSU::CatchHitObject.new(js[:nested].to_ptr + (i * LIBOSU::CatchHitObject.size))
	# 		print("[")
	# 		case nested_object[:type]
	# 		when :catchhitobject_fruit
	# 			print("f")
	# 		when :catchhitobject_droplet
	# 			print("d")
	# 		when :catchhitobject_tinydroplet
	# 			print("t")
	# 		end
	# 		print(" #{nested_object[:start_time].to_i} #{nested_object[:x].to_i} #{nested_object[:x_offset].to_i}]")
	# 	end
	when :catchhitobject_bananashower
		bs = LIBOSU::BananaShower.new(object[:cho][:bs])
		num = bs[:num_banana]
		if num % 2 != 0
			if $bs_faster_endtime.nil? || $bs_faster_endtime == 1
				$bs_faster_endtime = 1
			end
			bs_ho = LIBOSU::HitObject.new
			bs_ho[:x] = 256
			bs_ho[:y] = 192
			bs_ho[:time] = Practise.rng[:time]
			bs_ho[:type] = :nc_spinner
			bs_ho[:hit_sound] = 1
			bs_ho[:ho][:spinner][:end_time] = Practise.rng[:time] + $bs_faster_endtime
			loop do
				bs_obj = LIBOSU::CatchHitObject.new
				LIBOSU.ooc_bananashower_init(bs_obj, bs_ho)
				LIBOSU.ooc_bananashower_createnestedbananas(bs_obj)
				bs_new = LIBOSU::BananaShower.new(bs_obj[:cho][:bs])
				if bs_new[:num_banana] == 3
					output = FFI::MemoryPointer.new(:pointer)
					LIBOSU.ofb_hitobject_tostring(output, bs_ho)
					LIBOSU.fprintf(Practise.output, output.read_pointer.read_string)
					break
				end
				$bs_faster_endtime += 1
				bs_ho[:ho][:spinner][:end_time] += 1
			end
			num -= 3
		end
		num /= 2
		num.times do | i |
			bs_ho = LIBOSU::HitObject.new
			bs_ho[:x] = 256
			bs_ho[:y] = 192
			bs_ho[:time] = Practise.rng[:time]
			bs_ho[:type] = :nc_spinner
			bs_ho[:hit_sound] = 1
			bs_ho[:ho][:spinner][:end_time] = Practise.rng[:time] + 1
			output = FFI::MemoryPointer.new(:pointer)
			LIBOSU.ofb_hitobject_tostring(output, bs_ho)
			LIBOSU.fprintf(Practise.output, output.read_pointer.read_string)
		end
	end
end

def practise_time(hit_object)
	if hit_object[:time] < Practise.time[:start] || hit_object[:time] > Practise.time[:end]
		return
	end

	output = FFI::MemoryPointer.new(:pointer)
	LIBOSU.ofb_hitobject_tostring(output, hit_object);
	LIBOSU.fprintf(Practise.output, output.read_pointer.read_string)
end

def practise_main
	# Create the map to store all the data in
	map = LIBOSU::Beatmap.new
	LIBOSU.of_beatmap_init(map)
	LIBOSU.of_beatmap_set(map, Practise.beatmap)

	# Rename the map to tell the player what section of the map they are playing
	practise_rename(map)

	# Populate map with the `beginning` argument
	practise_beginning(map)
	
	# Process rng and populate map based on the rng
	if !(Practise.rng[:time].nil? || Practise.rng[:position].nil?)
		objects, objects_num = practise_rng_processor(map)
		objects_num.times do | i |
			object = LIBOSU::CatchHitObject.new(objects.to_ptr + (i * LIBOSU::CatchHitObject.size))
			practise_rng(object)
		end
	end

	# Record only the requested sections of the map
	map[:num_ho].times do | i |
		hit_object = LIBOSU::HitObject.new(map[:hit_objects].to_ptr + (i * LIBOSU::HitObject.size))
		practise_time(hit_object)
	end

	LIBOSU.fclose(Practise.beatmap)
	LIBOSU.fclose(Practise.output)
end