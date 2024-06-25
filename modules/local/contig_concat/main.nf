process CONTIG_CONCAT {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/pysam:0.22.1--py38h2d19e03_1':
        'biocontainers/pysam:0.22.1--py38h2d19e03_1' }"

    input:
    tuple val(meta), path(fasta, stageAs: 'input/*')

    output:
    tuple val(meta), path("*", type: 'file'), emit: fasta

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    contig_concat.py $fasta
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${meta.genome_name}.fa
    """
}
