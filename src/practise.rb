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

POSITION = 256
def practise_rng(hit_object, rng, map)
	# TODO RNG/+HARDROCK
	if !Practise.rng || hit_object[:time] >= Practise.time[:start]
		return
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

	object
	LIBOSU.ooc_processor_applypositionoffsetrng(object, 1, rng, Practise.hardrock)
	
	case object[:type]
	when :catchhitobject_fruit
		print("[f #{object[:start_time].to_i} #{object[:x].to_i} #{object[:x_offset].to_i}]")
		# POSITION - (object[:x].to_i + object[:x_offset].to_i)
	when :catchhitobject_juicestream
		js = LIBOSU::JuiceStream.new(object[:cho][:js])
		print("[j]")
		js[:num_nested].times do | i |
			nested_object = LIBOSU::CatchHitObject.new(js[:nested].to_ptr + (i * LIBOSU::CatchHitObject.size))
			print("[")
			case nested_object[:type]
			when :catchhitobject_fruit
				print("f")
			when :catchhitobject_droplet
				print("d")
			when :catchhitobject_tinydroplet
				print("t")
			end
			print(" #{nested_object[:start_time].to_i} #{nested_object[:x].to_i} #{nested_object[:x_offset].to_i}]")
		end
	when :catchhitobject_bananashower
		bs = LIBOSU::BananaShower.new(object[:cho][:bs])
		bs[:num_banana].times do | i |
			banana = LIBOSU::CatchHitObject.new(bs[:bananas].to_ptr)
			print("[b #{banana[:start_time].to_i} #{banana[:x].to_i} #{banana[:x_offset].to_i}]")
		end
	end
	puts("")

	output = FFI::MemoryPointer.new(:pointer)
	LIBOSU.ofb_hitobject_catchtostring(output, object);
	LIBOSU.fprintf(Practise.output, output.read_pointer.read_string)
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
	map = LIBOSU::Beatmap.new
	LIBOSU.of_beatmap_init(map)
	LIBOSU.of_beatmap_set(map, Practise.beatmap)

	practise_rename(map)
	practise_beginning(map)

	rng = LIBOSU::LegacyRandom.new
	LIBOSU.ou_legacyrandom_init(rng, LIBOSU.ooc_processor_RNGSEED)
	
	map[:num_ho].times do | i |
		hit_object = LIBOSU::HitObject.new(map[:hit_objects].to_ptr + (i * LIBOSU::HitObject.size))
		practise_rng(hit_object, rng, map)
		practise_time(hit_object)
	end

	LIBOSU.fclose(Practise.beatmap)
	LIBOSU.fclose(Practise.output)
end