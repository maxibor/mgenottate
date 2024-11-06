process MERGE_TABLES {
    tag "$meta.id"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pandas:2.2.1':
        'biocontainers/pandas:2.2.1' }"

    input:
    tuple val(meta), path(drep_genome_info), path(sdb), path(cdb), path(mmseqs)

    output:
    tuple val(meta), path("*_mgenottate_info.csv")   , emit: summary_table

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    merge_tables.py \\
        --drep_genome_info ${drep_genome_info} \\
        --sample_name ${meta.id} \\
        --sdb $sdb \\
        --cdb $cdb \\
        --mmseqs_taxo ${mmseqs} 
    """

    stub:
    """
    touch ${meta.id}_mgenottate_info.csv
    """
}
