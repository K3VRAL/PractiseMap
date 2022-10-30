#include "args.h"

#define args_arg_num 3
char *args_arg[args_arg_num][2] = {
	{ "-b", "--beatmap" },
	{ "-o", "--output" },
	{ "-h", "--help" }
};

bool args_beatmap(char *option) {
	FILE *fp = fopen(option, "r");
	if (fp == NULL) {
		return true;
	}
	practise.beatmap = fp;
	return false;
}

bool args_output(char *option) {
	FILE *fp = fopen(option, "w");
	if (fp == NULL) {
		return true;
	}
	practise.output = fp;
	return false;
}

void args_help(void) {
	char *title = "BananaPredictor";
	fprintf(stdout, "%s\n\n", title);

	char *usage = "bnprdctr [arguments]";
	fprintf(stdout, "usage:\n\t%s\n\n", usage);

	char *arguments[args_arg_num][2] = {
		{ "file", "inputs the beatmap from the file location" },
		{ "[file]", "outputs the BananaPredictor to the file location" },
		{ "", "gives this help message" }
	};
	// For the spaces
	int space_num = 0;
	for (int i = 0; i < args_arg_num; i++) {
		int num = strlen(*(*(args_arg + i) + 0)) + 2 + strlen(*(*(args_arg + i) + 1)) + strlen(*(*(arguments + i) + 0));
		if (num > space_num) {
			space_num = num;
		}
	}
	// Printing text with the spaces
	fprintf(stdout, "arguments:\n");
	for (int i = 0; i < args_arg_num; i++) {
		int num = space_num - (strlen(*(*(args_arg + i) + 0)) + 2 + strlen(*(*(args_arg + i) + 1)) + strlen(*(*(arguments + i) + 0)));
		fprintf(stdout, "\t%s, %s %s%*c%s\n", *(*(args_arg + i) + 0), *(*(args_arg + i) + 1), *(*(arguments + i) + 0), num + 1, ' ', *(*(arguments + i) + 1));
	}
}

void args_unknown(char *option) {
	fprintf(stdout, "Argument not found: %s\n", option);
}

bool args_main(int argc, char **argv) {
	for (int i = 1; i < argc; i++) {
		if (!strcmp(*(*(args_arg + 0) + 0), *(argv + i)) || !strcmp(*(*(args_arg + 0) + 1), *(argv + i))) {
			if (args_beatmap(*(argv + ++i))) {
				continue;
			}
		} else if (!strcmp(*(*(args_arg + 1) + 0), *(argv + i)) || !strcmp(*(*(args_arg + 1) + 1), *(argv + i))) {
			if (args_output(*(argv + ++i))) {
				continue;
			}
		} else if (!strcmp(*(*(args_arg + args_arg_num - 1) + 0), *(argv + i)) || !strcmp(*(*(args_arg + args_arg_num - 1) + 1), *(argv + i))) {
			args_help();
			return false;
		} else {
			args_unknown(*(argv + i));
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