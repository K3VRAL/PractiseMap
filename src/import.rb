require "ffi"

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

class Beatmap < FFI::Struct
	layout	:structure, Structure,
			:general, General,
			:editor, Editor,
			:metadata, Metadata,
			:difficulty, Difficulty,
			:events, :pointer,
			:num_event, :uint,
			:timing_points, :pointer,
			:num_tp, :uint,
			:colours, :pointer,
			:num_colour, :uint,
			:hit_objects, :pointer,
			:num_ho, :uint32
end

module LIBOSU
	extend FFI::Library
	ffi_lib ["stdio", "osu"]

	attach_function :fopen, [:string, :string], :pointer
	attach_function :fclose, [:pointer], :void

	attach_function :of_beatmap_init, [Beatmap.by_ref], :void
	attach_function :of_beatmap_free, [Beatmap.by_value], :void
	attach_function :of_beatmap_set, [Beatmap.by_ref, :pointer], :void
end