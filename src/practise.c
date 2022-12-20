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
	int buffer_num = strlen("Version:") + 1 + time_start + 1 + time_end + 1;
	char *buffer = calloc(buffer_num, sizeof(*buffer));
	snprintf(buffer, buffer_num, "Version: %d-%d", practise.time.start, practise.time.end);
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

CatchHitObject *practise_rng_processor(HitObject hit_object, Beatmap map, LegacyRandom *rng, float **last_position, double *last_start_time) {
	if (hit_object.time >= practise.time.start) {
		return NULL;
	}
	CatchHitObject *object = calloc(1, sizeof(*object));
	switch (hit_object.type) {
		case circle:
		case nc_circle:
			ooc_fruit_init(object, &hit_object);
			break;

		case slider:
		case nc_slider:
			ooc_juicestream_initwslidertp(object, *map.difficulty, map.timing_points, map.num_tp, &hit_object);
			ooc_juicestream_createnestedjuice(object);
			break;

		case spinner:
		case nc_spinner:
			ooc_bananashower_init(object, &hit_object);
			ooc_bananashower_createnestedbananas(object);
			break;
	}
	ooc_processor_applypositionoffsetrng(object, 1, rng, practise.hardrock, last_position, last_start_time);
	return object;
}

void practise_rng(CatchHitObject object, Beatmap map) {
	switch (object.type) {
		case catchhitobject_fruit: {
			static unsigned int js_faster_length = 1;
			HitObject js_ho = {
				.x = practise.rng.position,
				.y = 384,
				.time = practise.rng.time,
				.type = nc_slider,
				.hit_sound = 1,
				.ho.slider.curve_type = slidertype_linear,
				.ho.slider.slides = 1,
				.ho.slider.length = js_faster_length,
			};
			js_ho.ho.slider.num_curve = 1;
			js_ho.ho.slider.curves = calloc(1, sizeof(*js_ho.ho.slider.curves));
			(js_ho.ho.slider.curves + js_ho.ho.slider.num_curve)->x = practise.rng.position;
			(js_ho.ho.slider.curves + js_ho.ho.slider.num_curve)->y = 0;

			while (true) {
				CatchHitObject js_obj = {0};
				ooc_juicestream_initwslidertp(&js_obj, *map.difficulty, map.timing_points, map.num_tp, &js_ho);
				ooc_juicestream_createnestedjuice(&js_obj);
				if (js_obj.cho.js->num_nested == 4) {
					char *output = NULL;
					ofb_hitobject_tostring(&output, js_ho);
					fprintf(practise.output, "%s", output);
					free(output);
					break;
				}
				js_ho.ho.slider.length++;
				js_faster_length = js_ho.ho.slider.length;
			}
			break;
		}

		case catchhitobject_juicestream:
			// TODO
			break;

		case catchhitobject_bananashower: {
			unsigned int num = object.cho.bs->num_banana;
			if (num % 2 != 0) {
				static unsigned int bs_faster_endtime = 1;
				HitObject bs_ho = {
					.x = 256,
					.y = 192,
					.time = practise.rng.time,
					.type = nc_spinner,
					.hit_sound = 1,
					.ho.spinner.end_time = practise.rng.time + bs_faster_endtime,
				};

				while (true) {
					CatchHitObject bs_obj = {0};
					ooc_bananashower_init(&bs_obj, &bs_ho);
					ooc_bananashower_createnestedbananas(&bs_obj);
					if (bs_obj.cho.bs->num_banana == 3) {
						char *output = NULL;
						ofb_hitobject_tostring(&output, bs_ho);
						fprintf(practise.output, "%s", output);
						free(output);
						break;
					}
					bs_ho.ho.spinner.end_time++;
					bs_faster_endtime++;
				}
				num -= 3;
			}
			num /= 2;
			for (int i = 0; i < num; i++) {
				HitObject bs_ho = {
					.x = 256,
					.y = 192,
					.time = practise.rng.time,
					.type = nc_spinner,
					.hit_sound = 1,
					.ho.spinner.end_time = practise.rng.time + 1
				};
				char *output = NULL;
				ofb_hitobject_tostring(&output, bs_ho);
				fprintf(practise.output, "%s", output);
				free(output);
			}
			break;
		}
			
		case catchhitobject_droplet:
		case catchhitobject_tinydroplet:
		case catchhitobject_banana:
			break;
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
	// TODO see if this application is error free

	// Create the map to store all the data
	Beatmap map = {0};
	of_beatmap_init(&map);
	of_beatmap_set(&map, practise.beatmap);

	// Rename the map to tell the player what section of the map they are playing
	practise_rename(map);

	// Populate map with the `beginning` argument
	practise_beginning(map);

	// Process rng and populate map based on the rng
	if (!(practise.rng.time == 0 || practise.rng.position == 0)) {
		LegacyRandom rng = {0};
		ou_legacyrandom_init(&rng, ooc_processor_RNGSEED);
		float *last_position = NULL;
		double last_start_time = 0;

		CatchHitObject *objects = NULL;
		unsigned int objects_num = 0;
		for (int i = 0; i < map.num_ho; i++) {
			CatchHitObject *object = practise_rng_processor(*(map.hit_objects + i), map, &rng, &last_position, &last_start_time);
			if (object == NULL) {
				continue;
			}
			practise_rng(*object, map);
			
			objects = realloc(objects, ++objects_num * sizeof(*objects));
			*(objects + objects_num - 1) = *object;
			free(object);
		}
		ooc_hitobject_freebulk(objects, objects_num);
	}

	// Record only the requested sections of the map
	practise_time(map);

	of_beatmap_free(map);
}