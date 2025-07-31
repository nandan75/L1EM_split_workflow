// File: modules/run_L1EM.nf

process realign_and_split_reads {

    tag "$sample_id"

    input:
    tuple val(sample_id), path(bam), path(bai)
    val ref_genome
    path L1EM_path

    output:
    tuple val(sample_id), path("split_fqs"), path("idL1reads"), path("*.aln.bam"), path(L1EM_path)

    script:
    """
    module load singularity
    module load bwa
    module load samtools
    module load python3/3.12.1 

    cp $bam input.bam
    cp $bai input.bam.bai

    realign_and_split_reads.sh input.bam $L1EM_path $ref_genome
    """
}


process make_gr_matrix {

    tag "$sample_id"

    input:
    tuple val(sample_id), path(split_fqs), path(idL1reads), path(aln_bams), path(L1EM_path)
    val ref_genome

    output:
    tuple val(sample_id), path("G_of_R"), path("baminfo.txt"), path(L1EM_path)

    script:
    """
    module load singularity
    module load bwa
    module load samtools
    module load python3/3.12.1

    cp ${split_fqs}/*.bam split_fqs/
    make_gr_matrix.sh idL1reads/realigned.bam $L1EM_path
    """
}


process expectation_maximization {

    tag "$sample_id"

    input:
    tuple val(sample_id), path("G_of_R"), path("baminfo.txt"), path(L1EM_path)

    output:
    tuple val(sample_id), path("full_counts.txt"), path("filter_L1HS_FPM.txt")

    output:
    tuple val(sample_id), path("l1hs_transcript_counts.txt"), emit: l1hs_transcript_counts, optional: true
    tuple val(sample_id), path("filter_L1HS_FPM.txt"), emit: filter_L1HS_FPM, optional: true
    tuple val(sample_id), path("full_counts.txt"), emit: full_counts, optional: true

    publishDir "${params.outdir}/${sample_id}/", mode: 'copy'

    script:
    """
    module load singularity
    module load bwa
    module load samtools
    module load python3/3.12.1

    expectation_maximization.sh $L1EM_path
    """
}


workflow run_L1EM {

    take:
    input_bams
    ref_genome
    L1EM_path

    main:
    realigned_out = realign_and_split_reads(input_bams, ref_genome, L1EM_path)
    gr_matrix_out = make_gr_matrix(realigned_out, ref_genome)
    em_out        = expectation_maximization(gr_matrix_out)



}

