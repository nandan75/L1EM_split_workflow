#!/usr/bin/env nextflow

// To use DSL-2 will need to include this
nextflow.enable.dsl=2

// Default command to launch is:
//                              nextflow run main.nf -profile [load_profile],[dataset_profile]
//                              where [load_profile] is the profile for your machine and [dataset_profile] the one for your datasets paths and variables!



//params.fqpattern = "*.bam"

// Import processes or subworkflows to be run in the workflow

// Download using copyq
include { download_git_and_references } from './modules/download_git_and_references'

// Run L1EM
//include { run_L1EM } from './modules/run_L1EM'
include { realign_and_split_reads } from './modules/realign_and_split_reads'
include { make_gr_matrix } from './modules/make_gr_matrix'
include { expectation_maximization } from './modules/expectation_maximization'


// Print a header for your pipeline
log.info """\

=======================================================================================
O N T - B A C P A C K - nf
=======================================================================================

Created by TODO NAME
Find documentation @ TODO INSERT LINK
Cite this pipeline @ TODO INSERT DOI

=======================================================================================
Workflow run parameters
=======================================================================================
input       : ${params.input}
results     : ${params.outdir}
workDir     : ${workflow.workDir}
=======================================================================================

"""


/// Help function
// This is an example of how to set out the help function that
// will be run if run command is incorrect or missing.

def helpMessage() {
    log.info"""
  Usage: nextflow run main.nf -resume --samples <SAMPLES_FILE>


  Required Arguments:

  --input_directory   Specify full path and name of directory.
//  --samplesheet       Spectify full path and name of samplesheet csv.

  Optional Arguments:

  --outdir              Specify path to output directory.
  --multiqc_config      Configure multiqc reports
  --sequencing_summary  Sequencing summary log from sequencer

""".stripIndent()
}



// Define workflow structure. Include some input/runtime tests here.
// See https://www.nextflow.io/docs/latest/dsl2.html?highlight=workflow#workflow
workflow {
    if (!params.samples) {
        error "Missing required parameter: --samples"
    }

    bamFilesChannel = Channel
    .fromPath(params.samples)
    .splitCsv(header: true)
    .map { row -> 
        def sample_id = row.sample_id
        def rna_tumor = file(row.rna_tumor_path)
        def rna_tumor_bai = file(row.rna_tumor_bai_path)
    
        tuple(sample_id, rna_tumor, rna_tumor_bai)
    }
    

    //Download
    download_git_and_references()
    L1EM_PATH=download_git_and_references.out.L1EM_git


    //download_references_and_images.out.rep_lib.view { "Downloaded folder path: $it" }
    
    //REF=download_references_and_images.out.REF


    // Run L1EM
    //run_L1EM(bamFilesChannel,params.ref_genome, L1EM_PATH)

    realign_and_split_reads(bamFilesChannel, params.ref_genome, L1EM_PATH)
    split_fqs = realign_and_split_reads.out.split_fqs
    idL1reads = realign_and_split_reads.out.idL1reads 

    make_gr_matrix(bamFilesChannel,split_fqs,idL1reads,L1EM_PATH)
    baminfo = make_gr_matrix.out.baminfo
    G_of_R = make_gr_matrix.out.G_of_R
    expectation_maximization(baminfo,G_of_R,L1EM_PATH)


}




