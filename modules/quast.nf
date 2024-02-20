process quast {

    tag { sample_id }

    input:
    tuple val(sample_id), path(assembly)

    output:
    tuple val(sample_id), path("${sample_id}_quast.tsv"), emit: tsv
    tuple val(sample_id), path("${sample_id}_quast_provenance.yml"), emit: provenance

    script:
    """
    printf -- "- process_name: quast\\n"                  >> ${sample_id}_quast_provenance.yml
    printf -- "  tools:\\n"                               >> ${sample_id}_quast_provenance.yml
    printf -- "    - tool_name: quast\\n"                 >> ${sample_id}_quast_provenance.yml
    printf -- "      tool_version: \$(quast --version | cut -d ' ' -f 2 | tr -d 'v')\\n" >> ${sample_id}_quast_provenance.yml
    printf -- "      parameters:\\n"                      >> ${sample_id}_quast_provenance.yml
    printf -- "        - parameter: --space-efficient\\n" >> ${sample_id}_quast_provenance.yml
    printf -- "          value: null\\n"                  >> ${sample_id}_quast_provenance.yml
    printf -- "        - parameter: --fast\\n"            >> ${sample_id}_quast_provenance.yml
    printf -- "          value: null\\n"                  >> ${sample_id}_quast_provenance.yml
    printf -- "        - parameter: --min-contig\\n"      >> ${sample_id}_quast_provenance.yml
    printf -- "          value: 0\\n"                     >> ${sample_id}_quast_provenance.yml

    quast --threads ${task.cpus} \
        --space-efficient \
	--fast \
	--min-contig 0 \
        ${assembly}  \
	--output-dir ${sample_id}

    mv ${sample_id}/transposed_report.tsv ${sample_id}_quast.tsv
    """
}

process parse_quast_report {

    tag { sample_id }

    executor 'local'

    publishDir "${params.outdir}/${sample_id}", pattern: "${sample_id}_quast.csv", mode: 'copy'

    input:
    tuple val(sample_id), path(quast_report)

    output:
    tuple val(sample_id), path("${sample_id}_quast.csv")

    script:
    """
    parse_quast_report.py ${quast_report} > ${sample_id}_quast.csv
    """
}
