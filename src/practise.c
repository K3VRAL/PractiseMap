#include "practise.h"

#include <osu.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

Practise practise = {
	.beatmap = NULL,

	.output = NULL,

	.time = {
		.start = 0,
		.end = 0
	},

	.beginning = NULL,
	.beginning_num = 0,
	
	.rng = {
		.time = 0,
		.position = 0
	},
	.hardrock = false
};

void practise_rename(Beatmap map) {
	int time_start = ou_comparing_size(practise.time.start);
	int time_end = ou_comparing_size(practise.time.end);
	int buffer_num = strlen("Version:") + 1 + 1 + time_start + 1 + time_end + 1;
	char *buffer = calloc(buffer_num, sizeof(*buffer));
	snprintf(buffer, buffer_num, "Version: %c%d-%d", practise.rng.time || practise.rng.position ? (practise.hardrock ? 'h' : 'r') : 'n', practise.time.start, practise.time.end);
	free(map.metadata->version);
	ofb_metadata_setfromstring(map.metadata, buffer);
	free(buffer);

	HitObject *temp = map.hit_objects;
	unsigned int temp_num = map.num_ho;
	map.hit_objects = NULL;
	map.num_ho = 0;
	of_beatmap_tofile(practise.output, map);
	map.hit_objects = temp;
	map.num_ho = temp_num;
}

void practise_beginning(Beatmap map) {
	for (int i = 0; i < practise.beginning_num; i++) {
		for (int j = 0; j < (practise.beginning + i)->amount; j++) {
			HitObject object = {
				.x = 256,
				.y = 192,
				.time = (practise.beginning + i)->time,
				.type = nc_circle,
				.hit_sound = 0,
				.hit_sample = {0}
			};
			char *output = NULL;
			ofb_hitobject_tostring(&output, object);
			fprintf(practise.output, "%s", output);
			free(output);
		}
	}
}

void practise_rng(Beatmap map) {
	LegacyRandom rng = {0};
	ou_legacyrandom_init(&rng, ooc_processor_RNGSEED);

	float *last_position = NULL;
	double last_start_time = 0;

	unsigned int rng_num = 0;

	for (int i = 0; i < map.num_ho; i++) {
		if ((map.hit_objects + i)->time >= practise.time.start) {
			break;
		}
		CatchHitObject *object = calloc(1, sizeof(*object));
		switch ((map.hit_objects + i)->type) {
			case circle:
			case nc_circle:
				ooc_fruit_init(object, (map.hit_objects + i));
				break;

			case slider:
			case nc_slider:
				ooc_juicestream_initwslidertp(object, *map.difficulty, map.timing_points, map.num_tp, (map.hit_objects + i));
				ooc_juicestream_createnestedjuice(object);
				break;

			case spinner:
			case nc_spinner:
				ooc_bananashower_init(object, (map.hit_objects + i));
				ooc_bananashower_createnestedbananas(object);
				break;
		}
		LegacyRandom old_rng = rng;
		ooc_processor_applypositionoffsetrng(object, 1, &rng, practise.hardrock, &last_position, &last_start_time);
		while (!(old_rng.w == rng.w
			&& old_rng.x == rng.x
			&& old_rng.y == rng.y
			&& old_rng.z == rng.z)) {
				ou_legacyrandom_nextuint(&old_rng);
				rng_num++;
		}
		ooc_hitobject_freebulk(object, 1);
	}

	free(last_position);

	unsigned int rng_div = rng_num / (4 * 2);
	unsigned int rng_mod = rng_num % (4 * 2);

	for (int i = 0; i < rng_div; i++) {
		HitObject bs_ho = {
			.x = 256,
			.y = 192,
			.time = practise.rng.time,
			.type = nc_spinner,
			.hit_sound = 0,
			.ho.spinner.end_time = practise.rng.time + 1,
			.hit_sample = {0}
		};
		char *output = NULL;
		ofb_hitobject_tostring(&output, bs_ho);
		fprintf(practise.output, "%s", output);
		free(output);
	}

	for (int i = 0; i < rng_mod; i++) {
		static unsigned int js_faster_length = 1;
		HitObject js_ho = {
			.x = practise.rng.position,
			.y = 384,
			.time = practise.rng.time,
			.type = nc_slider,
			.hit_sound = 0,
			.ho.slider = {
				.curve_type = slidertype_linear,
				.curves = NULL,
				.num_curve = 1,
				.slides = 1,
				.length = js_faster_length
			},
			.hit_sample = {0}
		};
		js_ho.ho.slider.curves = calloc(js_ho.ho.slider.num_curve, sizeof(*js_ho.ho.slider.curves));
		(js_ho.ho.slider.curves + js_ho.ho.slider.num_curve - 1)->x = practise.rng.position;
		(js_ho.ho.slider.curves + js_ho.ho.slider.num_curve - 1)->y = 0;
		while (true) {
			CatchHitObject js_obj = {0};
			ooc_juicestream_initwslidertp(&js_obj, *map.difficulty, map.timing_points, map.num_tp, &js_ho);
			ooc_juicestream_createnestedjuice(&js_obj);
			if (js_obj.cho.js->num_nested == 3) {
				char *output = NULL;
				ofb_hitobject_tostring(&output, js_ho);
				fprintf(practise.output, "%s", output);
				free(output);
				oos_hitobject_free(js_ho);
				ooc_hitobject_free(js_obj);
				break;
			}
			ooc_hitobject_free(js_obj);
			js_faster_length++;
			js_ho.ho.slider.length = js_faster_length;
		}
	}
}

void practise_time(Beatmap map) {
	for (int i = 0; i < map.num_ho; i++) {
		if ((map.hit_objects + i)->time < practise.time.start || (map.hit_objects + i)->time > practise.time.end) {
			continue;
		}
		char *output = NULL;
		ofb_hitobject_tostring(&output, *(map.hit_objects + i));
		fprintf(practise.output, "%s", output);
		free(output);
	}
}

void practise_main() {
	// Create the map to store all the data
	Beatmap map = {0};
	of_beatmap_init(&map);
	of_beatmap_set(&map, practise.beatmap);

	// Rename the map to tell the player what section of the map they are playing
	practise_rename(map);

	// Populate map with the `beginning` argument
	practise_beginning(map);

	// Process rng and populate map based on the rng
	practise_rng(map);

	// Record only the requested sections of the map
	practise_time(map);

	of_beatmap_free(map);
}