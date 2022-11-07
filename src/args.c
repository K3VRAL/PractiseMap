#include "args.h"

#define args_arg_num 7
char *args_arg[args_arg_num][4] = {
	{ "-b", "--beatmap", "file", "inputs the beatmap from the file location" },
	{ "-o", "--output", "[file]", "outputs the BananaPredictor to the file location" },
	{ "-t", "--time", "start,end", "start and end time to start including the objects" },
	{ "-g", "--beginning", "[time,amount]", "gives the time and amount of objects to be placed before the beatmap starts" },
	{ "-r", "--rng", "", "keeps track of the rng elements of the map and outputs it to the beginning of the map" },
	{ "-d", "--hardrock", "", "keeps track of the rng elements given that hardrock is enabled; relies on `-r` to be enabled" },
	{ "-h", "--help", "", "gives this help message" }
};

void args_beatmap(bool *assign, char *option) {
	FILE *fp = fopen(option, "r");
	if (fp == NULL) {
		*assign = false;
		return;
	}
	practise.beatmap = fp;
}

void args_output(bool *assign, char *option) {
	FILE *fp = fopen(option, "w");
	if (fp == NULL) {
		*assign = false;
		return;
	}
	practise.output = fp;
}

void args_time(char *option) {
	practise.time = realloc(practise.time, ++practise.time_num * sizeof(*practise.time));
	(practise.time + practise.time_num - 1)->start = (int) strtol(strtok(option, ","), NULL, 10);
	(practise.time + practise.time_num - 1)->end = strtol(strtok(NULL, ","), NULL, 10);
}

void args_beginning(char *option) {
	practise.beginning = realloc(practise.beginning, ++practise.beginning_num * sizeof(*practise.beginning));
	(practise.beginning + practise.beginning_num - 1)->time = (int) strtol(strtok(option, ","), NULL, 10);
	(practise.beginning + practise.beginning_num - 1)->num = strtoul(strtok(NULL, ","), NULL, 10);
}

void args_rng(void) {
	practise.rng = true;
}

void args_hardrock(void) {
	practise.hardrock = true;
}

void args_help(void) {
	char *title = "PractiseMap";
	fprintf(stdout, "%s\n\n", title);

	char *usage = "pracmap [arguments]";
	fprintf(stdout, "usage:\n\t%s\n\n", usage);

	// For the spaces
	int space_num = 0;
	for (int i = 0; i < args_arg_num; i++) {
		int num = strlen(*(*(args_arg + i) + 0)) + 2 + strlen(*(*(args_arg + i) + 1)) + strlen(*(*(args_arg + i) + 2));
		if (num > space_num) {
			space_num = num;
		}
	}
	// Printing text with the spaces
	fprintf(stdout, "arguments:\n");
	for (int i = 0; i < args_arg_num; i++) {
		int num = space_num - (strlen(*(*(args_arg + i) + 0)) + 2 + strlen(*(*(args_arg + i) + 1)) + strlen(*(*(args_arg + i) + 2)));
		fprintf(stdout, "\t%s, %s %s%*c%s\n", *(*(args_arg + i) + 0), *(*(args_arg + i) + 1), *(*(args_arg + i) + 2), num + 1, ' ', *(*(args_arg + i) + 3));
	}
}

void args_unknown_argument(char *option) {
	fprintf(stdout, "Argument not found: %s\n", option);
}

void args_main(bool *keep_running, int argc, char **argv) {
	for (int i = 1; i < argc; i++) {
		if (!strcmp(*(*(args_arg + 0) + 0), *(argv + i)) || !strcmp(*(*(args_arg + 0) + 1), *(argv + i))) {
			bool assign = true;
			args_beatmap(&assign, *(argv + ++i));
			if (!assign) {
				fprintf(stdout, "Beatmap file not found: %s\n", *(argv + i));
			}
		} else if (!strcmp(*(*(args_arg + 1) + 0), *(argv + i)) || !strcmp(*(*(args_arg + 1) + 1), *(argv + i))) {
			bool assign = true;
			args_output(&assign, *(argv + ++i));
			if (!assign) {
				fprintf(stdout, "Output file not possible: %s - defaulting to stdout\n", *(argv + i));
				practise.output = stdout;
			}
		} else if (!strcmp(*(*(args_arg + 2) + 0), *(argv + i)) || !strcmp(*(*(args_arg + 2) + 1), *(argv + i))) {
			args_time(*(argv + ++i));
		} else if (!strcmp(*(*(args_arg + 3) + 0), *(argv + i)) || !strcmp(*(*(args_arg + 3) + 1), *(argv + i))) {
			args_beginning(*(argv + ++i));
		} else if (!strcmp(*(*(args_arg + 4) + 0), *(argv + i)) || !strcmp(*(*(args_arg + 4) + 1), *(argv + i))) {
			args_rng();
		} else if (!strcmp(*(*(args_arg + 5) + 0), *(argv + i)) || !strcmp(*(*(args_arg + 5) + 1), *(argv + i))) {
			args_hardrock();
		} else if (!strcmp(*(*(args_arg + args_arg_num - 1) + 0), *(argv + i)) || !strcmp(*(*(args_arg + args_arg_num - 1) + 1), *(argv + i))) {
			args_help();
			*keep_running = false;
			return;
		} else {
			args_unknown_argument(*(argv + i));
			*keep_running = false;
			return;
		}
	}

	if (practise.output == NULL) {
		practise.output = stdout;
	}

	if (practise.beatmap == NULL) {
		*keep_running = false;
		return;
	}
}