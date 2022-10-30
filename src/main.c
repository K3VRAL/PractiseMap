#include "main.h"

int main(int argc, char **argv) {
	// Handle arguments given and make a few tests before we run things
	bool keep_running = true;
	args_main(&keep_running, argc, argv);

	if (keep_running) {
		// Where the magic happens
		practise_main();
	}

	// Free
	if (practise.beatmap != NULL) {
		fclose(practise.beatmap);
	}
	if (practise.output != stdout) {
		fclose(practise.output);
	}

	return 0;
}