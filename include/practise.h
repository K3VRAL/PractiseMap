#ifndef PRACTISE_H
#define PRACTISE_H

#include <stdbool.h>
#include <stdio.h>
#include <unistd.h>
#include <unistd.h>
#include <sys/ioctl.h>

#include <osu.h>

typedef struct Practise {
	FILE *beatmap;

	FILE *output;

	struct {
		int start;
		int end;
	} *time;
	unsigned int time_num;

	struct {
		int time;
		unsigned int num;
	} *beginning;
	unsigned int beginning_num;

	bool rng;
	bool hardrock;
} Practise;

extern Practise practise;

void practise_main(void);

#endif