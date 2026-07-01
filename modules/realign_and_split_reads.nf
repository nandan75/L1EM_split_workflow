process realign_and_split_reads {
    errorStrategy 'ignore' // Ignore errors
    tag "$sample_id"

    input:
    tuple val(sample_id), path(rna_tumor), path(rna_tumor_bai)
    val ref_genome
    path L1EM_PATH

    output:
    tuple val(sample_id), path("split_fqs"), emit : split_fqs
    tuple val(sample_id), path("idL1reads"), emit : idL1reads
    //tuple val(sample_id), path("*.aln.bam"), emit : aln_bams

    script:
    """
    module purge
    module load singularity
    module load bwa
    module load samtools
    module load python3/3.12.1

    # Enable error handling but continue the script on failure
    set +e

    rna_tumor=\$(realpath "${rna_tumor}")
    rna_tumor_bai=\$(realpath "${rna_tumor_bai}")
    L1EM_PATH=\$(realpath "${L1EM_PATH}")

    chmod +x \${L1EM_PATH}/generate_L1EM_fasta_and_index.sh
    chmod g+w \${L1EM_PATH}/utilities/*.py

    realign_and_split_reads.sh \\
        \${rna_tumor} \\
        \${L1EM_PATH} \\
        ${ref_genome}

    """
}

