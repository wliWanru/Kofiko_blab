/*
% Copyright (c) 2008 Shay Ohayon, California Institute of Technology.
% This file is a part of a free software. you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation (see GPL.txt)
*/
#include <stdio.h>
#include "mex.h"
#include <math.h>
#define MAX(x,y)(x>y)?(x):(y)
#define MIN(x,y)(x<y)?(x):(y)

	double fMatchWeight = 2;
	double fDeleteWeight = -1;
	double fMismatchWeight = -3;
	double Jitter = 0.001;

double fnWeight(double fA, double fB) {

	if (fabs(fA-fB) < Jitter)
		return fMatchWeight;
	else
		return fMismatchWeight;

}

void mexFunction( int nlhs, mxArray *plhs[], 
				 int nrhs, const mxArray *prhs[] ) 
{

	double	NaN = mxGetNaN();

	if (nrhs < 6)  {
		mexPrintf("Use: NeedlemanWunsch(A,B, [MatchWeight=2, DeleteWeight=-1, MismatchWeight = -3, Jitter=?\n");
		return;
	}

	double *A = (double*)mxGetData(prhs[0]);
	double *B = (double*)mxGetData(prhs[1]);

	fMatchWeight = *(double*)mxGetData(prhs[2]);
	fDeleteWeight = *(double*)mxGetData(prhs[3]);
	fMismatchWeight = *(double*)mxGetData(prhs[4]);
	Jitter = *(double*)mxGetData(prhs[5]);



	const int *dimA = mxGetDimensions(prhs[0]);
	int iA= MAX(dimA[0],dimA[1]);
	const int *dimB = mxGetDimensions(prhs[1]);
	int iB = MAX(dimB[0],dimB[1]);


	plhs[0] = mxCreateNumericArray(2, dimA, mxDOUBLE_CLASS, mxREAL);
	double *AtoB = (double*)mxGetPr(plhs[0]);
	for (int k=0;k<iA;k++)
		AtoB[k] = NaN;

	plhs[1] = mxCreateNumericArray(2, dimB, mxDOUBLE_CLASS, mxREAL);
	double *BtoA = (double*)mxGetPr(plhs[1]);

	for (int k=0;k<iB;k++)
		BtoA[k] = NaN;

	int AB = MAX(iA,iB);

	const int dimAB[2] = {1, AB};
	plhs[2] = mxCreateNumericArray(2, dimAB, mxDOUBLE_CLASS, mxREAL);
	double *AlignmentA = (double*)mxGetPr(plhs[2]);
	
	plhs[3] = mxCreateNumericArray(2, dimAB, mxDOUBLE_CLASS, mxREAL);
	double *AlignmentB = (double*)mxGetPr(plhs[3]);


	for (int k=0;k<AB;k++) {
		AlignmentA[k] = AlignmentB[k] = NaN;
	}

	// Initialize score matrix

	int NumRows = iA+1;
	int NumCols = iB+1;
	int N = NumRows*NumCols;
	double *F = new double[N];
	for (int k=0;k<N;k++) {
		F[k] = NaN;
	}
	for (int k=0;k<NumRows;k++) {
		F[k] = fDeleteWeight*k;
	}

	for (int k=0;k<NumCols;k++) {
		F[k*NumRows+0] = fDeleteWeight*k;
	}

	// Compute score matrix
	for (int i=1;i<NumRows;i++) {
		for (int j=1;j<NumCols;j++) {

			double fMatch = F[i-1 + (j-1)*NumRows] + fnWeight(A[i-1],B[j-1]);
			double fDelete = F[i-1 + (j)*NumRows] + fDeleteWeight;
			double fInsert = F[i + (j-1)*NumRows] + fDeleteWeight;
			F[j*NumRows+i] = MAX( MAX(fMatch, fInsert), fDelete);
		}
	}

	// Backtrack
	int i  = iA;
	int j  = iB;
	int c = AB-1;
	while (i > 0 || j > 0) {
		if (i > 0 && j > 0 && F[i+j*NumRows] == F[i-1 + (j-1)*NumRows] + fnWeight(A[i-1], B[j-1]))
		{
			AlignmentA[c]  = A[i-1];
			AlignmentB[c]  = B[j-1];
			if (i-1 < iA)
				AtoB[i-1] = j;
			if (j-1 < iB)
				BtoA[j-1] = i;

			i = i-1;
			j = j-1;
		} 
		else if (i > 0 && F[i+j*NumRows] == F[(i-1)+j*NumRows] + fDeleteWeight) 
		{
			AlignmentA[c]  = A[i-1];
			AlignmentB[c]  = NaN;
			i=i-1;
		} else {
			AlignmentA[c]  = NaN;
			AlignmentB[c]  = B[j-1];
			j=j-1;
		}
		c = c -1;
	}

	delete [] F;
}
