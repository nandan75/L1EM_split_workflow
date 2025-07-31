#!/bin/bash

# Script to execute L1-EM pipeline (refactored for Nextflow compatibility)

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

# Command line arguments
bamfile=$1
L1EM_directory=$2
hg38=$3

# Paths
L1EM_bed=/scratch/ew19/nandan/tools/L1EM/installation/L1EM/annotation/default_index_files/L1EM.400.bed
L1EM_fa=/scratch/ew19/nandan/tools/L1EM/installation/L1EM/annotation/default_index_files/L1EM.400.fa
L1EM_code_dir="${L1EM_directory}/L1EM/"
L1EM_utilities_dir="${L1EM_directory}/utilities/"
L1EM_CGC_dir="${L1EM_directory}/CGC/"

# Working directories
WORKDIR=$(pwd)
IDREADS_DIR="${WORKDIR}/idL1reads"
SPLIT_DIR="${WORKDIR}/split_fqs"
GOR_DIR="${WORKDIR}/G_of_R"
L1EM_DIR="${WORKDIR}/L1EM"


# STEP 1: Realign
echo 'STEP 1: realign'
mkdir -p "$IDREADS_DIR"
cd "$IDREADS_DIR"
$samtools view -@ $threads -b -F 2 "$bamfile" | $samtools sort -@ $threads -n - | $samtools fastq - -1 unaligned.fq1 -2 unaligned.fq2
$bwa aln -k $realignNM -n $realignNM -t $threads -i $bwa_i "$hg38" unaligned.fq1 > 1.sai
$bwa aln -k $realignNM -n $realignNM -t $threads -i $bwa_i "$hg38" unaligned.fq2 > 2.sai
$bwa sampe "$hg38" 1.sai 2.sai unaligned.fq1 unaligned.fq2 | $samtools view -b -@ $threads - | $samtools sort -@ $threads - > realigned.bam
samtools index realigned.bam

# STEP 2: Extract L1HS/L1PA* aligning reads
echo 'STEP 2: extract'
python3 "${L1EM_utilities_dir}read_or_pair_overlap_bed.py" "$L1EM_bed" "$bamfile" temp.bam
$samtools sort -@ $threads -n temp.bam | $samtools fastq - -1 L1.fq1 -2 L1.fq2
python3 "${L1EM_utilities_dir}read_or_pair_overlap_bed.py" "$L1EM_bed" realigned.bam temp.bam
$samtools sort -@ $threads -n temp.bam | $samtools fastq - -1 temp.fq1 -2 temp.fq2
cat temp.fq1 >> L1.fq1
cat temp.fq2 >> L1.fq2
cd "$WORKDIR"

# STEP 3: Split fastqs
echo 'STEP 3: split fastqs'
mkdir -p "$SPLIT_DIR"
split_fq_size=$(wc -l "$IDREADS_DIR/L1.fq1" | awk '{print $1/('$threads'*4)+1}' | cut -d '.' -f 1 | awk '{print $1*4}')
split -l $split_fq_size "$IDREADS_DIR/L1.fq1" "$SPLIT_DIR/L1.fq1."
split -l $split_fq_size "$IDREADS_DIR/L1.fq2" "$SPLIT_DIR/L1.fq2."
cd "$SPLIT_DIR"

# STEP 4: Generate candidate alignments
echo 'STEP 4: candidate alignments'
for name in *.fq1.*
  do reads1=$name
  reads2=$(echo $name|sed 's/fq1/fq2/g')
  ref=$L1EM_fa
  base=$(echo $name|sed 's/.fq1//g')
  $bwa aln -t $threads -N -n $L1EM_NM -k $L1EM_NM -i $bwa_i -R 10000000 $ref $reads1 > $base.R1.aln.sai
  $bwa aln -t $threads -N -n $L1EM_NM -k $L1EM_NM -i $bwa_i -R 10000000 $ref $reads2 > $base.R2.aln.sai
  $bwa sampe -n 10000000 -N 10000000 $ref $base.R1.aln.sai $base.R2.aln.sai $reads1 $reads2 | $samtools view -bS - | $samtools sort -n - > $base.aln.bam &
done

