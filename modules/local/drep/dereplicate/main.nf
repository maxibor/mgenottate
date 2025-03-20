process DREP_DEREPLICATE {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/drep:3.5.0--pyhdfd78af_0':
        'biocontainers/drep:3.5.0--pyhdfd78af_0' }"

    input:
    tuple val(meta), path(genomeInfo), path(genomes)

    output:
    tuple val(meta), path("figures/*.pdf"), emit: pdf
    tuple val(meta), path("data_tables/*.csv"), emit: csv
    tuple val(meta), path("dereplicated_genomes/*"), emit: dereplicated_genomes
    tuple val(meta), path("data_tables/genomeInfo.csv"), emit: genomeInfo
    tuple val(meta), path("data_tables/Sdb.csv"), emit: sdb
    tuple val(meta), path("data_tables/Cdb.csv"), emit: cdb
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """

    filter_drep_input.py \\
        --busco_sum_in $genomeInfo \\
        --busco_sum_out ${prefix}.busco_summary_clean.csv \\
        --genomes_out ${prefix}_genomes.txt

    dRep \\
        dereplicate \\
        ./ \\
        --processors $task.cpus \\
        --genomeInfo ${prefix}.busco_summary_clean.csv \\
        --genomes ${prefix}_genomes.txt \\
        $args


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        drep: \$(samtools --version |& sed '1!d ; s/samtools //')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir -p figures
    touch Clustering_scatterplots.pdf

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        drep: \$(dRep |& grep "...::: dRep" | sed 's/[ \t]*...::: dRep //' | sed 's/ :::...[ \t]*//')
    END_VERSIONS
    """
}
