require_relative "import"

class Practise
	@beatmap	= nil
	@output		= nil
	@time		= (Struct.new(:start, :end)).new
	@beginning	= Array.new
	@rng		= false
	@hardrock	= false

	class << self
		attr_accessor :beatmap, :output, :time, :beginning, :rng, :hardrock
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

def practise_rng(hit_object, rng, map)
	# TODO RNG/+HARDROCK
	if !Practise.rng || hit_object[:time] > Practise.time[:start]
		return
	end

	object = LIBOSU::CatchHitObject.new
	# TODO What's going wrong here?
	case hit_object[:type]
	# when :circle, :nc_circle
	# 	LIBOSU.ooc_fruit_init(object, hit_object)
	# when :slider, :nc_slider
	# 	LIBOSU.ooc_juicestream_initwslidertp(object, map[:difficulty], map[:timing_points], map[:num_tp], hit_object)
	# 	LIBOSU.ooc_juicestream_createnestedjuice(object)
	when :spinner, :nc_spinner
		LIBOSU.ooc_bananashower_init(object, hit_object)
		LIBOSU.ooc_bananashower_createnestedbananas(object)
	end

	LIBOSU.ooc_processor_applypositionoffsetrng(object, 1, rng, Practise.hardrock)
end

def practise_time(hit_object)
	if hit_object[:time] >= Practise.time[:start] && hit_object[:time] <= Practise.time[:end]
		output = FFI::MemoryPointer.new(:pointer, 1)
		LIBOSU.ofb_hitobject_tostring(output, hit_object);
		LIBOSU.fprintf(Practise.output, output.read_pointer.read_string)
	end
end

def practise_main
	map = LIBOSU::Beatmap.new
	LIBOSU.of_beatmap_init(map)
	LIBOSU.of_beatmap_set(map, Practise.beatmap)

	practise_rename(map)
	practise_beginning(map)

	rng = LIBOSU::LegacyRandom.new
	LIBOSU.ou_legacyrandom_init(rng, LIBOSU.ooc_processor_RNGSEED)
	
	pointer = map[:hit_objects].to_ptr
	map[:num_ho].times do | i |
		hit_object = LIBOSU::HitObject.new(pointer + (i * LIBOSU::HitObject.size))
		practise_rng(hit_object, rng, map)
		practise_time(hit_object)
	end

	LIBOSU.fclose(Practise.beatmap)
	LIBOSU.fclose(Practise.output)
end