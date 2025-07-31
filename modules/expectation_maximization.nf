process expectation_maximization {
  
    tag "$sample_id"
    publishDir "${params.outdir}/${sample_id}/", mode: 'copy'	


    input:
    tuple val(sample_id), path(baminfo)
    tuple val(sample_id), path(G_of_R)
    path L1EM_PATH

    output:
     tuple val(sample_id), path("l1hs_transcript_counts.txt"), emit: l1hs_transcript_counts ,  optional: true
     tuple val(sample_id), path("filter_L1HS_FPM.txt"), emit: filter_L1HS_FPM ,  optional: true
     tuple val(sample_id), path("full_counts.txt"), emit: full_counts ,  optional: true


    script:
    """
    module load singularity
    module load bwa
    module load samtools
    module load python3/3.12.1 


    L1EM_PATH=\$(realpath "${L1EM_PATH}")
    baminfo=\$(realpath "${baminfo}")
    G_of_R=\$(realpath "${G_of_R}")     

 
    expectation_maximization.sh \\
        \${baminfo} \\
        \${G_of_R} \\
        \${L1EM_PATH}    
 

    """


}

