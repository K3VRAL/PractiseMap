#include "main.h"

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
	// Handle arguments given and make a few tests before we run things
	bool keep_running = args_main(argc, argv);

	if (keep_running) {
		// Where the magic happens
		practise_main();
	}

	// Free
	if (practise.beatmap != NULL) {
		fclose(practise.beatmap);
	}
	if (practise.output != stdout && practise.output != NULL) {
		fclose(practise.output);
	}
	if (practise.beginning != NULL) {
		free(practise.beginning);
	}

	return !keep_running;
}