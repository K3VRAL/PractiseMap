#include "args.h"
#include "practise.h"

#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

bool args_beatmap(char *option) {
	if (practise.beatmap != NULL) {
		fprintf(stdout, "Input file has already been inputted despite attempting to input [%s]\n", option);
		return false;
	}
	FILE *fp = fopen(option, "r");
	if (fp == NULL) {
		fprintf(stdout, "Error: Input file [%s] has not been found\n", option);
		return false;
	}
	practise.beatmap = fp;
	return true;
}

bool args_output(char *option) {
	if (practise.output != NULL) {
		fprintf(stdout, "Error: Output file has already been inputted despite attempting to input [%s]\n", option);
		return false;
	}
	FILE *fp = fopen(option, "w");
	if (fp == NULL) {
		fprintf(stdout, "Error: Output file [%s] is not possible\n", option);
		return false;
	}
	practise.output = fp;
	return true;
}

bool args_time(char *option) {
	char *start = strtok(option, ",");
	char *end = strtok(NULL, ",");
	if (start == NULL || end == NULL) {
		fprintf(stdout, "Error: Time [%s] [%s][%s] requires the start time and end time\n", option, start, end);
		return false;
	}

	practise.time.start = (int) strtol(start, NULL, 10);
	practise.time.end = strtol(end, NULL, 10);
	return true;
}

bool args_beginning(char *option) {
	char *time = strtok(option, ",");
	char *amount = strtok(NULL, ",");
	if (time == NULL || amount == NULL) {
		fprintf(stdout, "Error: Beginning [%s] [%s][%s] requires the time and the amount\n", option, time, amount);
		return false;
	}

	practise.beginning = realloc(practise.beginning, ++practise.beginning_num * sizeof(*practise.beginning));
	(practise.beginning + practise.beginning_num - 1)->time = (int) strtol(time, NULL, 10);
	(practise.beginning + practise.beginning_num - 1)->amount = strtoul(amount, NULL, 10);
	return true;
}

bool args_rng(char *option) {
	char *time = strtok(option, ",");
	char *position = strtok(NULL, ",");
	if (time == NULL || position == NULL) {
		fprintf(stdout, "Error: RNG [%s] [%s][%s] requires the time and the position\n", option, time, position);
		return false;
	}

	practise.rng.time = (int) strtol(time, NULL, 10);
	practise.rng.position = strtoul(position, NULL, 10);
	return true;
}

void args_hardrock(void) {
	practise.hardrock = true;
}

void args_help(void);

typedef struct Args {
	char *i;
	char *item;
	char *argument;
	char *description;
	enum {
		cp,
		v,
		rv
	} e_function;
	union {
		bool (*cp)(char *);
		void (*v)(void);
	} function;
} Args;
#define args_num 7
Args args_arg[args_num] = {
	{
		.i = "-b",
		.item = "--beatmap",
		.argument = "file",
		.description = "inputs the file to be read and manipulated",
		.e_function = cp,
		.function = {
			.cp = args_beatmap
		}
	},
	{
		.i = "-o",
		.item = "--output",
		.argument = "[file]",
		.description = "outputs the manipulated file",
		.e_function = cp,
		.function = {
			.cp = args_output
		}
	},
	{
		.i = "-t",
		.item = "--time",
		.argument = "start,end",
		.description = "start and end time to start including the objects",
		.e_function = cp,
		.function = {
			.cp = args_time
		}
	},
	{
		.i = "-g",
		.item = "--beginning",
		.argument = "[time,amount]",
		.description = "gives the time and amount of objects to be placed before the beatmap starts",
		.e_function = cp,
		.function = {
			.cp = args_beginning
		}
	},
	{
		.i = "-r",
		.item = "--rng",
		.argument = "",
		.description = "keeps track of the rng elements of the map and outputs it to the beginning of the map",
		.e_function = cp,
		.function = {
			.cp = args_rng
		}
	},
	{
		.i = "-d",
		.item = "--hardrock",
		.argument = "",
		.description = "keeps track of the rng elements given that hardrock is enabled; relies on `-r` to be used",
		.e_function = v,
		.function = {
			.v = args_hardrock
		}
	},
	// { // TODO
	// 	.i = "-i",
	// 	.item = "--instant-skip",
	// 	.argument = "",
	// 	.description = "immediately skips map to the first object",
	// 	.e_function = v,
	// 	.function = {
	// 		.v = 
	// 	}
	// },
	{
		.i = "-h",
		.item = "--help",
		.argument = "",
		.description = "gives this help message",
		.e_function = rv,
		.function = {
			.v = args_help
		}
	}
};

void args_help(void) {
	char *title = "PractiseMap";
	fprintf(stdout, "%s\n\n", title);

	char *usage = "pracmap [arguments]";
	fprintf(stdout, "usage:\n\t%s\n\n", usage);

	// For the spaces
	int space_num = 0;
	for (int i = 0; i < args_num; i++) {
		int num = strlen((args_arg + i)->i) + 2 + strlen((args_arg + i)->item) + strlen((args_arg + i)->argument);
		if (num > space_num) {
			space_num = num;
		}
	}
	// Printing text with the spaces
	fprintf(stdout, "arguments:\n");
	for (int i = 0; i < args_num; i++) {
		int num = space_num - (strlen((args_arg + i)->i) + 2 + strlen((args_arg + i)->item) + strlen((args_arg + i)->argument));
		fprintf(stdout, "\t%s, %s %s%*c%s\n", (args_arg + i)->i, (args_arg + i)->item, (args_arg + i)->argument, num + 1, ' ', (args_arg + i)->description);
	}
}

bool args_main(int argc, char **argv) {
	for (int i = 1; i < argc; i++) {
		bool not_found = true;
		for (int j = 0; j < args_num; j++) {
			if (!strcmp((args_arg + j)->i, *(argv + i)) || !strcmp((args_arg + j)->item, *(argv + i))) {
				if ((args_arg + j)->e_function == cp) {
					if (!(args_arg + j)->function.cp(*(argv + ++i))) {
						return false;
					}
				} else if ((args_arg + j)->e_function == v) {
					(args_arg + j)->function.v();
				} else if ((args_arg + j)->e_function == rv) {
					(args_arg + j)->function.v();
					return false;
				}
				not_found = false;
				break;
			}
		}
		if (not_found) {
			fprintf(stdout, "Error: Argument not found: %s\n", *(argv + i));
			return false;
		}
	}

	if (practise.output == NULL) {
		practise.output = stdout;
	}

	if (practise.beatmap == NULL) {
		return false;
	}

	return true;
}