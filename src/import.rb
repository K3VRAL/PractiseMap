require "ffi"

module LIBOSU
	extend FFI::Library
	ffi_lib FFI::Library::LIBC
	ffi_lib "osu"

	attach_function :fopen, [ :string, :string ], :pointer
	attach_function :fclose, [ :pointer ], :void
	attach_function :fprintf, [ :pointer, :string, :varargs ], :void
	attach_variable :stdout, :pointer

	class LegacyRandom < FFI::Struct
		layout(		:w, :uint, 
				:x, :uint, 
				:y, :uint, 
				:z, :uint, 
				:bitBuffer, :uint, 
				:bitIndex, :int
		)
	end
	attach_variable :ooc_processor_RNGSEED, :int
	attach_function :ou_legacyrandom_init, [ LegacyRandom.by_ref, :int ], :void
	attach_function :ou_legacyrandom_nextuint, [ LegacyRandom.by_ref ], :void

	class Metadata < FFI::Struct
		layout(		:title, :string,
				:title_unicode, :string,
				:artist, :string,
				:artist_unicode, :string,
				:creator, :string,
				:version, :string,
				:source, :string,
				:tags, :pointer,
				:num_tag, :uint,
				:beatmap_id, :int,
				:beatmap_set_id, :int
		)
	end
	attach_function :ofb_metadata_setfromstring, [ Metadata.by_ref, :string ], :void

	class Difficulty < FFI::Struct
		layout(		:hp_drain_rate, :double,
				:circle_size, :double,
				:overall_difficulty, :double,
				:approach_rate, :double,
				:slider_multiplier, :double,
				:slider_tick_rate, :double
		)
	end

	class TimingPoint < FFI::Struct
		layout(		:time, :int,
				:beat_length, :double,
				:meter, :int,
				:sample_set, :int,
				:sample_index, :int,
				:volume, :int,
				:uninherited, :bool,
				:effects, :int
		)
	end
	attach_function :realloc, [ :pointer, :size_t ], TimingPoint.ptr # Not sure how to make ruby not compain that this isn't another type

	SliderType = enum(
		:slidertype_catmull, "C".ord,
		:slidertype_bezier, "B".ord,
		:slidertype_linear, "L".ord,
		:slidertype_perfectcurve, "P".ord
	)
	class HOSliderCurve < FFI::Struct
		layout(	:x, :int,
				:y, :int
		)
	end
	class HOSlider < FFI::Struct
		layout(		:curve_type, SliderType,
				:curves, HOSliderCurve.ptr,
				:num_curve, :uint,
				:slides, :int,
				:length, :double,
				:edge_sounds, :pointer,
				:num_edge_sound, :uint,
				:edge_sets, :pointer,
				:num_edge_set, :uint 
		)
	end
	class HOSpinner < FFI::Struct
		layout(		:end_time, :int
		)
	end
	class HOSample < FFI::Struct
		layout(		:normal_set, :int,
				:addition_set, :int,
				:index, :int,
				:volume, :int,
				:filename, :string
		)
	end
	class HO < FFI::Union
		layout(		:slider, HOSlider,
				:spinner, HOSpinner
		)
	end
	HOType = enum(
		:circle, 1,
		:nc_circle, 5,
		:slider, 2,
		:nc_slider, 6,
		:spinner, 8,
		:nc_spinner, 12
	)
	class HitObject < FFI::Struct
		layout(		:x, :int,
				:y, :int,
				:time, :int,
				:type, HOType,
				:hit_sound, :int,
				:ho, HO,
				:hit_sample, HOSample
		)
	end

	class Beatmap < FFI::Struct
		layout(		:structure, :pointer,
				:general, :pointer,
				:editor, :pointer,
				:metadata, Metadata.ptr,
				:difficulty, Difficulty.ptr,
				:events, :pointer,
				:num_event, :uint,
				:timing_points, TimingPoint.ptr,
				:num_tp, :uint,
				:colours, :pointer,
				:num_colour, :uint,
				:hit_objects, HitObject.ptr,
				:num_ho, :uint32
		)
	end
	attach_function :of_beatmap_init, [ Beatmap.by_ref ], :void
	attach_function :of_beatmap_set, [ Beatmap.by_ref, :pointer ], :void
	attach_function :of_beatmap_tofile, [ :pointer, Beatmap.by_value ], :void
	attach_function :ofb_hitobject_tostring, [ :pointer, HitObject.by_value ], :void
	attach_function :ofb_timingpoint_addfromstring, [ :pointer, :string ], :void

	class CHO < FFI::Union
		layout(		:f, :pointer,
				:js, :pointer, # Would've been nice if I could forward declare this
				:bs, :pointer, # Would've been nice if I could forward declare this
				:b, :pointer,
				:d, :pointer,
				:td, :pointer
		)
	end
	CHOType = enum(
		:catchhitobject_fruit,
		:catchhitobject_juicestream,
		:catchhitobject_bananashower,
		:catchhitobject_banana,
		:catchhitobject_droplet,
		:catchhitobject_tinydroplet
	)
	class CatchHitObject < FFI::Struct
		layout(		:start_time, :float,
				:x, :float,
				:x_offset, :float,
				:type, CHOType,
				:cho, CHO,
				:refer, HitObject.ptr
		)
	end
	class JuiceStream < FFI::Struct
		layout(		:nested, CatchHitObject.ptr,
				:num_nested, :uint,
				:slider_data, :pointer
		)
	end
	class BananaShower < FFI::Struct
		layout(		:end_time, :int,
				:duration, :int,
				:bananas, CatchHitObject.ptr,
				:num_banana, :uint
		)
	end
	attach_function :ooc_fruit_init, [ CatchHitObject.by_ref, HitObject.by_ref ], :void
	attach_function :ooc_juicestream_initwslidertp, [ CatchHitObject.by_ref, Difficulty.by_value, TimingPoint.ptr, :uint, HitObject.by_ref ], :void
	attach_function :ooc_juicestream_createnestedjuice, [ CatchHitObject.by_ref ], :void
	attach_function :ooc_bananashower_init, [ CatchHitObject.by_ref, HitObject.by_ref ], :void
	attach_function :ooc_bananashower_createnestedbananas, [ CatchHitObject.by_ref ], :void
	attach_function :ooc_processor_applypositionoffsetrng, [ :pointer, :uint, LegacyRandom.by_ref, :bool, :pointer, :pointer ], :void
end