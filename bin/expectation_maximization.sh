#!/bin/bash
set -euo pipefail

threads=16
EM_threshold=1e-7

baminfo=$1
G_of_R=$2
L1EM_directory=$3

BASE_DIR=$(pwd)

mkdir -p "$BASE_DIR/L1EM"
cd "$BASE_DIR/L1EM"

ls ${G_of_R}/*pk2 > G_of_R_list.txt
cp $(ls ${G_of_R}/*TE_list.txt | head -1) TE_list.txt

python3 ${L1EM_directory}/L1EM/L1EM.py -g G_of_R_list.txt -l TE_list.txt -t $threads -s $EM_threshold

python3 ${L1EM_directory}/utilities/L1EM_readpairs.py >> ${baminfo}
python3 ${L1EM_directory}/utilities/report_l1_exp_counts.py > ${BASE_DIR}/full_counts.txt
python3 ${L1EM_directory}/utilities/report_l1hs_transcription.py > ${BASE_DIR}/l1hs_transcript_counts.txt
python3 ${L1EM_directory}/utilities/filtered_and_normalized_l1hs.py names_final.pkl X_final.pkl \
    $(head -2 "$BASE_DIR"/baminfo.txt | tail -1) \
    $(head -3 "$BASE_DIR"/baminfo.txt | tail -1) > ${BASE_DIR}/filter_L1HS_FPM.txt

#cp *final.pkl "$BASE_DIR"/
#cd "$BASE_DIR"

