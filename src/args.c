#include "args.h"
#include "practise.h"

#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

bool args_beatmap(char *option) {
	if (practise.beatmap != NULL) {
		fprintf(stdout, "Error: Input file has already been inputted\n");
		return false;
	}
	FILE *fp = fopen(option, "r");
	if (fp == NULL) {
		fprintf(stdout, "Error: Input file returned an error\n");
		return false;
	}
	practise.beatmap = fp;
	return true;
}

bool args_output(char *option) {
	if (practise.output != NULL) {
		fprintf(stdout, "Error: Output file has already been inputted\n");
		return false;
	}
	FILE *fp = fopen(option, "w");
	if (fp == NULL) {
		fprintf(stdout, "Error: Output file is returned an error\n");
		return false;
	}
	practise.output = fp;
	return true;
}

void args_time(char *option) {
	practise.time.start = (int) strtol(strtok(option, ","), NULL, 10);
	practise.time.end = strtol(strtok(NULL, ","), NULL, 10);
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

void args_help(void);

typedef struct Args {
	char *i;
	char *item;
	char *argument;
	char *description;
	enum {
		bcp,
		cp,
		v,
		rv
	} e_function;
	union {
		bool (*bcp)(char *);
		void (*cp)(char *);
		void (*v)(void);
	} function;
} Args;
#define args_num 7
Args args_arg[args_num] = {
	{
		.i = "-b",
		.item = "--beatmap",
		.argument = "file",
		.description = "inputs the beatmap from the file location",
		.e_function = bcp,
		.function = {
			.bcp = args_beatmap
		}
	},
	{
		.i = "-o",
		.item = "--output",
		.argument = "[file]",
		.description = "outputs the objects to the file location",
		.e_function = bcp,
		.function = {
			.bcp = args_output
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
		.e_function = v,
		.function = {
			.v = args_rng
		}
	},
	{
		.i = "-d",
		.item = "--hardrock",
		.argument = "",
		.description = "keeps track of the rng elements given that hardrock is enabled; relies on `-r` to be enabled",
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
				if ((args_arg + j)->e_function == bcp) {
					if (!(args_arg + j)->function.bcp(*(argv + ++i))) {
						return false;
					}
				} else if ((args_arg + j)->e_function == cp) {
					(args_arg + j)->function.cp(*(argv + ++i));
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