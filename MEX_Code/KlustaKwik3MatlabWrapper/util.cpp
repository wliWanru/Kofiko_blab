/*
 * util.cpp
 *
 * Various utility functions.
 *
 *  Created on: 11 Nov 2011
 *      Author: dan
 */

#include "util.h"
#include<stdlib.h>
#include<stdarg.h>

const scalar HugeScore = (scalar)1e32;

/* integer random number between min and max*/
int irand(int min, int max)
{
    return (rand() % (max - min + 1) + min);
}

FILE *fopen_safe(char *fname, char *mode) {
    FILE *fp;

    fp = fopen(fname, mode);
    if (!fp) {
        fprintf(stderr, "Could not open file %s\n", fname);
        abort();
    }

    return fp;
}

// Print a matrix
void MatPrint(FILE *fp, scalar *Mat, int nRows, int nCols) {
    int i, j;

    for (i=0; i<nRows; i++) {
        for (j=0; j<nCols; j++) {
            fprintf(fp, "%.5g ", Mat[i*nCols + j]);
            Output("%.5g ", Mat[i*nCols + j]);
        }
        fprintf(fp, "\n");
        Output("\n");
    }
}
