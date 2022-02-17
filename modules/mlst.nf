process mlst {

    tag { sample_id }

    publishDir params.versioned_outdir ? "${params.outdir}/${sample_id}/${params.pipeline_short_name}-v${params.pipeline_minor_version}-output" : "${params.outdir}/${sample_id}", mode: 'copy', pattern: "${sample_id}_mlst.json"

    input:
    tuple val(sample_id), path(assembly)

    output:
    tuple val(sample_id), path("${sample_id}_mlst.csv"), path("${sample_id}_mlst.json"), emit: mlst
    tuple val(sample_id), path("${sample_id}_mlst_provenance.yml"), emit: provenance
    
    script:
    """
    printf -- "- process_name: mlst\\n" > ${sample_id}_mlst_provenance.yml
    printf -- "  tool_name: mlst\\n  tool_version: \$(mlst --version | cut -d ' ' -f 2)\\n  parameters:\\n" >> ${sample_id}_mlst_provenance.yml
    printf -- "  - parameter: minid\\n    value: ${params.minid}\\n" >> ${sample_id}_mlst_provenance.yml
    printf -- "  - parameter: mincov\\n    value: ${params.mincov}\\n" >> ${sample_id}_mlst_provenance.yml
    printf -- "  - parameter: minscore\\n    value: ${params.minscore}\\n" >> ${sample_id}_mlst_provenance.yml
    mlst \
      --minid ${params.minid} \
      --mincov ${params.mincov} \
      --minscore ${params.minscore} \
      --csv \
      --json ${sample_id}_mlst.json \
      ${assembly} > ${sample_id}_mlst.csv
    """
}

process parse_alleles {
    tag { sample_id }
    
    executor 'local'

    publishDir params.versioned_outdir ? "${params.outdir}/${sample_id}/${params.pipeline_short_name}-v${params.pipeline_minor_version}-output" : "${params.outdir}/${sample_id}", mode: 'copy', pattern: "${sample_id}_alleles.csv"
    publishDir params.versioned_outdir ? "${params.outdir}/${sample_id}/${params.pipeline_short_name}-v${params.pipeline_minor_version}-output" : "${params.outdir}/${sample_id}", mode: 'copy', pattern: "${sample_id}_sequence_type.csv"

    input:
    tuple val(sample_id), path(mlst_csv), path(mlst_json)

    output:
    tuple val(sample_id), path("${sample_id}_alleles.csv"), path("${sample_id}_sequence_type.csv")

    script:
    """
    parse_alleles.py -s ${sample_id} ${mlst_json} > ${sample_id}_alleles.csv
    echo 'sample_id' > sample_id.csv
    echo ${sample_id} >> sample_id.csv
    echo 'scheme,sequence_type' > sequence_type.csv
    cut -d ',' -f 2,3 ${mlst_csv} >> sequence_type.csv
    echo 'score' > score.csv
    awk -F ',' '{sum+=\$7}; END{print sum}' ${sample_id}_alleles.csv >> score.csv
    paste -d ',' sample_id.csv sequence_type.csv score.csv > ${sample_id}_sequence_type.csv
    """
}
