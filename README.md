# build-hmm
This repository contains scripts to build hmm protein profile.

Step 1: using cd-hit to cluster protein fasta file.
  "cdhit-count.pl" is used to count how many sequences per cluster.
  "split-fasta-by-clstr.pl" is used to split the main fasta file into cluster based on the output of cd-hit .clstr file.
  
Step 2: using MAFFT to align sequencses in each cluster.

Step 3: using Hmmbuild to build hmm profile for each cluster.
