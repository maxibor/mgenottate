process RESHAPE_DF {
    tag "$meta.id"
    label 'process_single'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pandas:2.2.1':
        'biocontainers/pandas:2.2.1' }"

    input:
    tuple val(meta), path(df)

    output:
    tuple val(meta), path("*.csv")                , emit: genome_information

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    reshape_busco_drep.py $df
    """

    stub:
    """
    touch genomeInformation.csv
    """
}
