require "ffi"

module LIBOSU
	extend FFI::Library
	ffi_lib FFI::Library::LIBC
	ffi_lib "osu"

	class TimingPoint < FFI::Struct
		layout	:time, :int,
				:beat_length, :double,
				:meter, :int,
				:sample_set, :int,
				:sample_index, :int,
				:volume, :int,
				:uninherited, :bool,
				:effects, :int
	end

	enum :SliderType, [
		:slidertype_catmull, 'C'.ord,
		:slidertype_bezier, 'B'.ord,
		:slidertype_linear, 'L'.ord,
		:slidertype_perfectcurve, 'P'.ord
	]
	class HOSlider < FFI::Struct
		layout	:curve_type, :SliderType,
				:curves, :pointer,
				:num_curve, :uint,
				:slides, :int,
				:length, :double,
				:edge_sounds, :pointer,
				:num_edge_sound, :uint,
				:edge_sets, :pointer,
				:num_edge_set, :uint 
	end
	class HOSpinner < FFI::Struct
		layout	:end_time, :int
	end
	class HOSample < FFI::Struct
		layout	:normal_set, :int,
				:addition_set, :int,
				:index, :int,
				:volume, :int,
				:filename, :string
	end
	class HO < FFI::Union
		layout	:slider, HOSlider,
				:spinner, HOSpinner
	end
	enum :HOType, [
		:circle, 1,
		:nc_circle, 5,
		:slider, 2,
		:nc_slider, 6,
		:spinner, 8,
		:nc_spinner, 12
	]
	class HitObject < FFI::Struct
		layout	:x, :int,
				:y, :int,
				:time, :int,
				:type, :HOType,
				:hit_sound, :int,
				:ho, HO,
				:hit_sample, HOSample
	end

	class Beatmap < FFI::Struct
		layout	:structure, :pointer,
				:general, :pointer,
				:editor, :pointer,
				:metadata, :pointer,
				:difficulty, :pointer,
				:events, :pointer,
				:num_event, :uint,
				:timing_points, TimingPoint.ptr,
				:num_tp, :uint,
				:colours, :pointer,
				:num_colour, :uint,
				:hit_objects, HitObject.ptr,
				:num_ho, :uint32
	end

	attach_function :fopen, [:string, :string], :pointer

	attach_function :of_beatmap_init, [Beatmap.by_ref], :void
	attach_function :of_beatmap_set, [Beatmap.by_ref, :pointer], :void
	
	attach_function :oos_hitobject_freebulk, [HitObject.by_ref, :uint], :void
end