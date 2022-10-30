#include "practise.h"

Practise practise = {
	.beatmap = NULL,
	.output = NULL,
	.time = {
		.start = 0,
		.end = 0
	},
	.beginning = {
		.time = 0,
		.amount = 0
	},
	.rng = false,
	.hardrock = false
};

/* Prints out the progress bar in the terminal. Resizing the terminal will also resize the output */
void predictor_progressbar(unsigned int percent) {
	struct winsize w;
	ioctl(STDOUT_FILENO, TIOCGWINSZ, &w);

	int size_terminal = w.ws_col - 2 - 1 - 3 - 1;
	int width = percent * size_terminal / 100;
	fprintf(stdout, "\r[");
	for (int i = 0; i < width; i++) {
		fprintf(stdout, "#");
	}
	for (int i = 0; i < size_terminal - width; i++) {
		fprintf(stdout, " ");
	}
	fprintf(stdout, "] %d%%", percent);
	fflush(stdout);
}

void practise_main() {
	if (practise.beatmap == NULL) {
		return;
	}

	Beatmap beatmap = {0};
	of_beatmap_init(&beatmap);
	of_beatmap_set(&beatmap, practise.beatmap);

	if (practise.output != stdout && practise.output != NULL) {
		HitObject *temp = beatmap.hit_objects;
		unsigned int temp_num = beatmap.num_ho;

		beatmap.hit_objects = NULL;
		beatmap.num_ho = 0;
		
		int time_start = ou_comparing_size(practise.time.start);
		int time_end = ou_comparing_size(practise.time.end);
		int buffer_num = strlen("Version:") + time_start + 1 + time_end + 1;
		char *buffer = calloc(buffer_num, sizeof(*buffer));
		free(beatmap.metadata->version);
		snprintf(buffer, buffer_num, "Version:%d-%d", practise.time.start, practise.time.end);

		ofb_metadata_setfromstring(beatmap.metadata, buffer);

		of_beatmap_tofile(practise.output, beatmap);

		beatmap.hit_objects = temp;
		beatmap.num_ho = temp_num;

		free(buffer);
	}

	for (int i = 0; i < practise.beginning.amount; i++) {
		HitObject object = {
			.x = 256,
			.y = 192,
			.time = practise.beginning.time,
			.type = nc_circle,
			.hit_sound = 0,
			.hit_sample = {0}
		};
		char *output = NULL;
		ofb_hitobject_tostring(&output, object);

		fprintf(practise.output, "%s", output);
		
		free(output);
	}

	for (int i = 0; i < beatmap.num_ho; i++) {
		if ((beatmap.hit_objects + i)->time >= practise.time.start && (beatmap.hit_objects + i)->time <= practise.time.end) {
			char *output = NULL;
			ofb_hitobject_tostring(&output, *(beatmap.hit_objects + i));
			
			fprintf(practise.output, "%s", output);
			
			free(output);
		}
	}

	// Free
	of_beatmap_free(beatmap);
}