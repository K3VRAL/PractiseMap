#include "practise.h"

Practise practise = {
	.beatmap = NULL,
	.output = NULL,
	.time = NULL,
	.time_num = 0,
	.beginning = NULL,
	.beginning_num = 0,
	.rng = false,
	.hardrock = false
};

void practise_beatmap(Beatmap beatmap) {
	HitObject *temp = beatmap.hit_objects;
	unsigned int temp_num = beatmap.num_ho;
	beatmap.hit_objects = NULL;
	beatmap.num_ho = 0;
	
	free(beatmap.metadata->version);
	int buffer_num = strlen("Version:") + 1;
	char *buffer = calloc(buffer_num, sizeof(*buffer));
	snprintf(buffer, buffer_num, "Version:");
	if (practise.output != stdout && practise.output != NULL) {
		for (int i = 0; i < practise.time_num; i++) {
			int time_start = ou_comparing_size((practise.time + i)->start);
			int time_end = ou_comparing_size((practise.time + i)->end);
			buffer_num += 1 + time_start + 1 + time_end;
			char *buffer = calloc(buffer_num, sizeof(*buffer));
			snprintf(buffer, buffer_num, " %d-%d", (practise.time + i)->start, (practise.time + i)->end);
		}
	}
	ofb_metadata_setfromstring(beatmap.metadata, buffer);
	free(buffer);
	of_beatmap_tofile(practise.output, beatmap);

	beatmap.hit_objects = temp;
	beatmap.num_ho = temp_num;
}

void practise_beginning(void) {
	// TODO eval rng/+hardrock
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
		for (int j = 0; j < practise.time_num; j++) {
			if ((beatmap.hit_objects + i)->time >= (practise.time + j)->start && (beatmap.hit_objects + i)->time <= (practise.time + j)->end) {
				char *output = NULL;
				ofb_hitobject_tostring(&output, *(beatmap.hit_objects + i));
				fprintf(practise.output, "%s", output);
				free(output);
			}
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
	practise_beginning();
	practise_time(beatmap);

	of_beatmap_free(beatmap);
}