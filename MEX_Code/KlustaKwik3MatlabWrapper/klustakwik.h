/*
 * Main header file
 */

#ifndef MASKED_KLUSTA_KWIK_2_H_
#define MASKED_KLUSTA_KWIK_2_H_

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <stdarg.h>
#include <iostream>
#include <fstream>
#include <vector>
#include <string.h>
#include "parameters.h"
#include "log.h"
#include "util.h"
#include "numerics.h"
#include "linalg.h"

using namespace std;

class KK {
public:
    /////////////// CONSTRUCTORS ///////////////////////////////////////////////
    // Construct from file
    KK(char *FileBase, int ElecNo, char *UseFeatures,
            scalar PenaltyK, scalar PenaltyKLogN, int PriorPoint);
    // Construct from subset of existing KK object
    void ConstructFrom(const KK &Source, const vector<int> &Indices);
    KK(const KK &Source, const vector<int> &Indices);
    // Make an entire copy of existing KK object
    KK(const KK &Source);
    /////////////// FUNCTIONS //////////////////////////////////////////////////
    void AllocateArrays();
    void Reindex();
    // Random initial starting conditions functions
    void StartingConditionsRandom();
    void StartingConditionsFromMasks();
    // Precomputation related functions
    void DoInitialPrecomputations();
    // Functions called by DoPrecomputations
    void DoPrecomputations();
    //SNK Precomputation for TrySplits to avoid changing NoiseMean and NoiseVariance and nMasked
    void ComputeUnmasked();
    void ComputeSortIndices();
    void ComputeSortedUnmaskedChangePoints();
    void ComputeNoiseMeansAndVariances();
    void ComputeCorrectionTermsAndReplaceData();
    void PointMaskDimension ();//SNK PointMaskDimension() computes the sum of the masks/float masks for each point  
    // Score and penalty functions
    scalar ComputeScore();
    scalar Penalty(int n);
    void ComputeClassPenalties();
    // Main algorithm functions
    void MStep();
    void EStep();
    void CStep(bool allow_assign_to_noise=true);
    void ConsiderDeletion();
    int TrySplits();
    scalar CEM(char *CluFile, int recurse, int InitRand, bool allow_assign_to_noise=true);
    scalar Cluster(char *CluFile);
    // IO related functions
    void LoadData(char *FileBase, int ElecNo, char *UseFeatures);
    void LoadClu(char *StartCluFile);
    void SaveOutput();
    void SaveTempOutput();
    void SaveSortedData();
    void SaveSortedClu();
    void SaveCovMeans();
public:
    /////////////// VARIABLES //////////////////////////////////////////////////
    int nDims, nDims2; // nDims2 is nDims squared and the mean of the unmasked dimensions.
    int nStartingClusters; // total # starting clusters, including clu 0, the noise cluster.
    int nClustersAlive; // nClustersAlive is total number with points in, excluding noise cluster
    int nPoints;
    int priorPoint; // Prior for regularization NOTE: separate from global variabl PriorPoint (capitalization)
    int NoisePoint; // number of fake points always in noise cluster to ensure noise weight>0
    int FullStep; // Indicates that the next E-step should be a full step (no time saving)
    scalar penaltyK, penaltyKLogN;
    vector<scalar> Data; // Data[p*nDims + d] = Input data for point p, dimension d
    
    // We sort the points into an order where the corresponding mask changes as
    // infrequently as possible, this vector is used to store the sorted indices,
    // see the function KK::ComputeSortIndices() in sortdata.cpp to see how this
    // sorting works. In the case of the TrySplits() function this sorting needs
    // to be recomputed when we change the underlying data.
    vector<int> SortedIndices;

    vector<int> Masks; //SNK: Masks[p*nDims + d] = Input masks for point p, dimension d
    vector<scalar> FloatMasks; // as above but for floating point masks
    // We store just the indices of the unmasked points in this sparse array
    // structure. For point p, the segment Unmasked[UnmaskedInd[p]] to
    // Unmasked[UnmaskedInd[p+1]] contains the indices i where Masks[i]==1.
    // This allows for a nice contiguous piece of memory without a separate
    // memory allocation for each point (and there can be many points). The
    // precomputation is performed by the function ComputeUnmasked(), and is
    // automatically called by LoadData() at the appropriate time, although
    // in the case of TrySplits() it has to be called explicitly.
    vector<int> Unmasked;
    vector<int> UnmaskedInd;
    // We also store a bool that tells us if the mask has changed when we go
    // through the points in sorted order. Computed by function
    // ComputeSortedUnmaskedChangePoints()
    vector<int> SortedMaskChange;
    
    vector<scalar> UnMaskDims; //SNK: Number of unmasked dimensions for each data point. In the Float masks case, the sum of the weights.
    vector<int> nClassMembers;
    
    vector<scalar> Weight; // Weight[c] = Class weight for class c
    vector<scalar> Mean; // Mean[c*nDims + d] = cluster mean for cluster c in dimension d
    vector<scalar> Cov; // Cov[c*nDims*nDims + i*nDims + j] = Covariance for cluster C, entry i,j
                    // NB covariances are stored in upper triangle (j>=i)
    vector<scalar> LogP; // LogP[p*MaxClusters + c] = minus log likelihood for point p in cluster c
    vector<int> Class; // Class[p] = best cluster for point p
    vector<int> OldClass; // Class[p] = previous cluster for point p
    vector<int> Class2; // Class[p] = second best cluster for point p
    vector<int> BestClass; // BestClass = best classification yet achieved
    vector<int> ClassAlive; // contains 1 if the class is still alive - otherwise 0
    vector<int> AliveIndex; // a list of the alive classes to iterate over

    // Used in EStep(), but this will probably change later
    vector<scalar> AllVector2Mean;
    // used in M step
    vector<scalar> NoiseMean;
    vector<scalar> NoiseVariance;
    vector<int> nMasked;
    // used in distribution EM steps
    vector<scalar> CorrectionTerm;
    vector<scalar> ClassCorrectionFactor;
    // used in ComputeScore and ConsiderDeletion
    vector<scalar> ClassPenalty;
    // debugging info
    int numiterations;
};

#endif /* MASKED_KLUSTA_KWIK_2_H_ */
