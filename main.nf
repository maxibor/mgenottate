#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    mgenottate
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/maxibor/mgenottate
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2


include { validateParameters; paramsSummaryLog; samplesheetToList } from 'plugin/nf-schema'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES AND SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { INITIALISE             } from './subworkflows/local/initialise'
include { GUNZIP                 } from './modules/nf-core/gunzip/main'
include { BUSCO_BUSCO            } from './modules/nf-core/busco/busco'
include { RESHAPE_DF             } from './modules/local/reshape_df'
include { DREP_DEREPLICATE       } from './modules/local/drep/dereplicate'
include { CONTIG_CONCAT          } from './modules/local/contig_concat'
include { CAT_CAT                } from './modules/nf-core/cat/cat'
include { MMSEQS_CONTIG_TAXONOMY } from './subworkflows/nf-core/mmseqs_contig_taxonomy'
include { MERGE_TABLES           } from './modules/local/merge_tables'

// Print parameter summary log to screen before running
log.info paramsSummaryLog(workflow)

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOW FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow MGENOTTATE {

    ch_versions = Channel.empty()

    INITIALISE()

    // Setting up database Channels
    ch_busco_db = params.busco_db ? Channel.fromPath(params.busco_db) : []

    ch_input = Channel.fromList(samplesheetToList(params.input, "assets/schema_input.json"))

    // See the documentation https://nextflow-io.github.io/nf-schema/samplesheets/fromSamplesheet/
    ch_input
        .map { 
            meta, genome_fa -> 
            def new_meta = meta + ['genome_name': genome_fa.simpleName]
            tuple(new_meta, genome_fa) 
            }
        .set { ch_input }

    ch_input
        .branch {
            compressed:   it[1].toString().tokenize(".")[-1] == 'gz'
            decompressed: it[1].toString().tokenize(".")[-1] != 'gz'
        }
        .set { genomes_fork }

    GUNZIP (
        genomes_fork.compressed
    )

    GUNZIP.out.gunzip
        .mix (genomes_fork.decompressed)
        .set { ch_genomes }

    BUSCO_BUSCO (
        ch_genomes,
        params.busco_mode,
        params.busco_lineage,
        ch_busco_db,
        []
    )

    BUSCO_BUSCO.out.batch_summary
        .collectFile(keepHeader: true) {
            meta, busco_summary -> 
                ["${meta.id}.busco_summary.tsv", busco_summary]
        }
        .set { ch_busco_summaries }

    ch_busco_summaries.map {
        it -> [['id': it.simpleName], it]
    }
    .set { ch_busco_summaries }
    
    ch_genomes.dump(tag: 'ch_genomes', pretty: true)

    RESHAPE_DF (
        ch_busco_summaries
    )

    RESHAPE_DF.out.genome_information.dump(tag: 'reshape_df', pretty: true)

    ch_genomes.map { 
                meta, genome -> 
                tuple(meta.subMap(['id']), genome)
            }.groupTuple().dump(tag: 'ch_genomes_groupTuple', pretty: true)

    RESHAPE_DF.out.genome_information.join(
            ch_genomes.map { 
                meta, genome -> 
                tuple(meta.subMap(['id']), genome)
            }.groupTuple()
        ).dump(tag: 'busco_join_df', pretty: true)

    DREP_DEREPLICATE (
        RESHAPE_DF.out.genome_information.join(
            ch_genomes.map { 
                meta, genome -> 
                tuple(meta.subMap(['id']), genome)
            }.groupTuple()
        )
    )

    DREP_DEREPLICATE.out.dereplicated_genomes.dump(tag: 'drep_dereplicated', pretty: true)

    CONTIG_CONCAT (
        DREP_DEREPLICATE.out.dereplicated_genomes.transpose()
    )

    CAT_CAT (
        CONTIG_CONCAT.out.fasta.groupTuple()
    )

    CONTIG_CONCAT.out.fasta.dump(tag: 'contig_concat', pretty: true)

    MMSEQS_CONTIG_TAXONOMY (
        CAT_CAT.out.file_out,
        params.mmseqs2_db_path,
        params.mmseqs2_db_name
    )

    MERGE_TABLES(
        DREP_DEREPLICATE.out.genomeInfo.join(
            MMSEQS_CONTIG_TAXONOMY.out.taxonomy
        )
    )
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
workflow {
    MGENOTTATE ()
}
