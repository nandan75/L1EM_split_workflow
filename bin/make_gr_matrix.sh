#!/bin/bash
set -euo pipefail

# Parameters
threads=16
realignNM=3
L1EM_NM=3
NMdiff=2
bwa_i=20
error_prob=0.01
max_start2start_len=500
reads_per_pickle=10000
EM_threshold=1e-7
template_fraction=1

# Binaries
bwa=$(which bwa)
samtools=$(which samtools)
python=$(which python)


bamfile=$1
split_fqs=$2
idL1reads=$3
L1EM_directory=$4

BASE_DIR=$(pwd)
bamfile_abs="$BASE_DIR/$bamfile"

# Paths
#L1EM_bed=/scratch/ew19/nandan/tools/L1EM/installation/L1EM/annotation/default_index_files/L1EM.400.bed
#L1EM_fa=/scratch/ew19/nandan/tools/L1EM/installation/L1EM/annotation/default_index_files/L1EM.400.fa
L1EM_bed=/g/data1a/ew19/CB/nandan/tools_installtions/L1EM_install/L1EM/annotation/L1EM.400.bed
L1EM_fa=/g/data1a/ew19/CB/nandan/tools_installtions/L1EM_install/L1EM/annotation/L1EM.400.fa


L1EM_code_dir="${L1EM_directory}/L1EM/"
L1EM_utilities_dir="${L1EM_directory}/utilities/"
L1EM_CGC_dir="${L1EM_directory}/CGC/"

mkdir "$BASE_DIR/G_of_R"
cd "$BASE_DIR/G_of_R"

python3 ${L1EM_directory}/CGC/median_template_and_pairs.py "$bamfile" 0.001 > "$BASE_DIR/baminfo.txt"
medianinsert=$(head -1 "$BASE_DIR/baminfo.txt")

for bam in ${split_fqs}/*.bam
do
    python3 ${L1EM_directory}/L1EM/G_of_R.py -b "$bam" -i "$medianinsert" -p $(basename "$bam") -e $error_prob -m $max_start2start_len -r $reads_per_pickle -n $NMdiff
done

