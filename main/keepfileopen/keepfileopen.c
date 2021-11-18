#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
	if (argc != 2) {
		fprintf(stderr, "Usage: keepfileopen <file>\n");
		return EXIT_FAILURE;
	}

	if (open(argv[1], O_RDONLY) < 0) {
		perror("Failed to open file");
		return EXIT_FAILURE;
	}

	pause();
	return EXIT_SUCCESS;
}
