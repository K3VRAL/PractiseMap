#ifndef PRACTISE_H
#define PRACTISE_H

#include <stdbool.h>
#include <stdio.h>

typedef struct Practise {
	FILE *beatmap;

	FILE *output;

	struct {
		int start;
		int end;
	} time;

	struct {
		int time;
		unsigned int amount;
	} *beginning;
	unsigned int beginning_num;

	struct {
		int time;
		unsigned short position;
	} rng;
	bool hardrock;
} Practise;

extern Practise practise;

void practise_main(void);

#endif