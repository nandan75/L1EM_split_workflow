process make_gr_matrix {
    tag "$sample_id" 
    errorStrategy 'ignore' // Ignore errors 
 
    input:
        tuple val(sample_id), path(rna_tumor), path(rna_tumor_bai)	
	tuple val(sample_id), path(split_fqs)
	tuple val(sample_id), path(idL1reads)
	path L1EM_PATH

    output:
	tuple val(sample_id), path("baminfo.txt"), emit:baminfo
        tuple val(sample_id), path(G_of_R), emit: G_of_R	

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
    split_fqs=\$(realpath "${split_fqs}")
    idL1reads=\$(realpath "${idL1reads}")

    make_gr_matrix.sh \\
        \${rna_tumor} \\
	\${split_fqs} \\
	\${idL1reads} \\
        \${L1EM_PATH} 

    """
}
