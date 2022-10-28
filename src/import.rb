require "ffi"

module LIBOSU
	extend FFI::Library
	ffi_lib FFI::Library::LIBC
	ffi_lib "osu"

	class Structure < FFI::Struct
		layout 	:version, :int
	end

	class General < FFI::Struct
		layout 	:audio_filename, :string,
				:audio_lead_in, :int,
				:audio_hash, :string,
				:preview_time, :int,
				:countdown, :int,
				:sample_set, :string,
				:stack_leniency, :double,
				:mode, :int,
				:letterbox_in_breaks, :bool,
				:story_fire_in_front, :bool,
				:use_skin_sprites, :bool,
				:always_show_playfield, :bool,
				:overlay_position, :string,
				:skin_preference, :string,
				:epilepsy_warning, :bool,
				:countdown_offset, :int,
				:special_style, :bool,
				:widescreen_storyboard, :bool,
				:samples_match_playback_rate, :bool
	end

	class Editor < FFI::Struct
		layout	:bookmarks, :pointer,
				:num_bookmark, :uint,
				:distance_spacing, :double,
				:beat_divisor, :double,
				:grid_size, :int,
				:timeline_zoom, :double
	end

	class Metadata < FFI::Struct
		layout	:title, :string,
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
	end

	class Difficulty < FFI::Struct
		layout	:hp_drain_rate, :double,
				:circle_size, :double,
				:overall_difficulty, :double,
				:approach_rate, :double,
				:slider_multiplier, :double,
				:slider_tick_rate, :double
	end

	# TODO class Event

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
	class HO < FFI::Union # TODO this is a union
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
		layout	:structure, Structure,
				:general, General,
				:editor, Editor,
				:metadata, Metadata,
				:difficulty, Difficulty,
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
end