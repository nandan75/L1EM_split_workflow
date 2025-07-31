process run_L1EM {
  //errorStrategy 'ignore' // Ignore errors
  tag "${sample_id}"

  publishDir "${params.outdir}/${sample_id}/", mode: 'copy'

input:
  tuple val(sample_id), path(rna_tumor), path(rna_tumor_bai)
  val ref_genome 
  path(L1EM_PATH)

//output:
//  tuple val(sample_id), path("l1hs_transcript_counts.txt"), emit: l1hs_transcript_counts ,  optional: true
//  tuple val(sample_id), path("filter_L1HS_FPM.txt"), emit: filter_L1HS_FPM ,  optional: true
//  tuple val(sample_id), path("full_counts.txt"), emit: full_counts ,  optional: true

script:

  """ 
  module load singularity
  module load bwa
  module load samtools
  module load python3/3.12.1

  # -------- VARIABLES ----------------

  L1EM_PATH=\$(realpath "${L1EM_PATH}")
  rna_tumor=\$(realpath "${rna_tumor}")
  rna_tumor_bai=\$(realpath "${rna_tumor_bai}")


  #sed -i -E -e 's|^python |python3 |' -e 's|\\\$python\\b|python3|g' \${L1EM_PATH}/run_L1EM.sh
  #sed -i 's|^mkdir ../L1EM/|mkdir -p ../L1EM/|' \${L1EM_PATH}/run_L1EM.sh 
  #sed -i -e "s|^L1EM_bed=.*|L1EM_bed=/scratch/ew19/nandan/tools/L1EM/installation/L1EM/annotation/default_index_files/L1EM.400.bed|" -e "s|^L1EM_fa=.*|L1EM_fa=/scratch/ew19/nandan/tools/L1EM/installation/L1EM/annotation/default_index_files/L1EM.400.fa|" \${L1EM_PATH}/run_L1EM.sh

  #cp /scratch/ew19/nandan/tools/L1EM/nextflow/retrobiome_nf/run_L1EM.sh \${L1EM_PATH}/
  
  #chmod +x \${L1EM_PATH}/run_L1EM.sh
  chmod +x \${L1EM_PATH}/generate_L1EM_fasta_and_index.sh
  chmod g+w \${L1EM_PATH}/utilities/*.py


  //REF="/scratch/ew19/nandan/tools/L1EM/reference/hg38.fa"

  \${L1EM_PATH}/run_L1EM.sh \\
        \${rna_tumor} \\
        \${L1EM_PATH} \\
        \${REF}




  """

}
