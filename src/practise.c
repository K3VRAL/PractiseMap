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
	
	.rng = false,
	.hardrock = false
};

void practise_beatmap(Beatmap beatmap) {
	int time_start = ou_comparing_size(practise.time.start);
	int time_end = ou_comparing_size(practise.time.end);
	int buffer_num = strlen("Version:") + 1 + time_start + 1 + time_end + 1;
	char *buffer = calloc(buffer_num, sizeof(*buffer));
	snprintf(buffer, buffer_num, "Version: %d-%d", practise.time.start, practise.time.end);
	free(beatmap.metadata->version);
	ofb_metadata_setfromstring(beatmap.metadata, buffer);
	free(buffer);

	HitObject *temp = beatmap.hit_objects;
	unsigned int temp_num = beatmap.num_ho;
	beatmap.hit_objects = NULL;
	beatmap.num_ho = 0;
	of_beatmap_tofile(practise.output, beatmap);
	beatmap.hit_objects = temp;
	beatmap.num_ho = temp_num;
}

void practise_beginning(Beatmap beatmap) {
	// TODO eval rng/+hardrock
	// if (practise.rng) {
	// 	CatchHitObject object = {0};
	// 	LegacyRandom rng = {0};
	// 	ou_legacyrandom_init(&rng, ooc_processor_RNGSEED);

	// 	for (int i = 0; i < beatmap.num_ho; i++) {
	// 		if ((beatmap.hit_objects + i)->time > practise.time.start) {
	// 			break;
	// 		}
	// 		switch ((beatmap.hit_objects + i)->type) {
	// 			case circle:
	// 			case nc_circle:
	// 				ooc_fruit_init(&object, (beatmap.hit_objects + i));
	// 				break;

	// 			case slider:
	// 			case nc_slider:
	// 				ooc_juicestream_initwslidertp(&object, *beatmap.difficulty, beatmap.timing_points, beatmap.num_tp, (beatmap.hit_objects + i));
	// 				ooc_juicestream_createnestedjuice(&object);
	// 				break;
				
	// 			case spinner:
	// 			case nc_spinner:
	// 				ooc_bananashower_init(&object, (beatmap.hit_objects + i));
	// 				ooc_bananashower_createnestedbananas(&object);
	// 				break;
	// 		}

	// 		ooc_processor_applypositionoffsetrngstarttime(&object, i, i + 1, &rng, practise.hardrock);

	// 		if (object.type == catchhitobject_juicestream) {
	// 			ooc_juicestream_free(object.cho.js);
	// 		} else if (object.type == catchhitobject_bananashower) {
	// 			ooc_bananashower_free(object.cho.bs);
	// 		}
	// 	}
	// }
	for (int i = 0; i < practise.beginning_num; i++) {
		for (int j = 0; j < (practise.beginning + i)->num; j++) {
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

void practise_time(Beatmap beatmap) {
	for (int i = 0; i < beatmap.num_ho; i++) {
		if ((beatmap.hit_objects + i)->time >= practise.time.start && (beatmap.hit_objects + i)->time <= practise.time.end) {
			char *output = NULL;
			ofb_hitobject_tostring(&output, *(beatmap.hit_objects + i));
			fprintf(practise.output, "%s", output);
			free(output);
		}
	}
}

void practise_main() {
	if (practise.beatmap == NULL) {
		return;
	}

	Beatmap beatmap = {0};
	of_beatmap_init(&beatmap);
	of_beatmap_set(&beatmap, practise.beatmap);

	practise_beatmap(beatmap);
	practise_beginning(beatmap);
	practise_time(beatmap);

	of_beatmap_free(beatmap);
}