process mlst {

    tag { sample_id }

    publishDir "${params.outdir}/${sample_id}", mode: 'copy', pattern: "${sample_id}_mlst.{csv,json}"

    input:
    tuple val(sample_id), path(assembly)

    output:
    tuple val(sample_id), path("${sample_id}_mlst.csv"), emit: csv
    tuple val(sample_id), path("${sample_id}_mlst.json"), emit: json
    tuple val(sample_id), path("${sample_id}_mlst_provenance.yml"), emit: provenance
    
    script:
    """
    printf -- "- tool_name: mlst\\n  tool_version: \$(mlst --version | cut -d ' ' -f 2)\\n  parameters:\\n" > ${sample_id}_mlst_provenance.yml
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

    publishDir "${params.outdir}/${sample_id}", mode: 'copy', pattern: "${sample_id}_alleles.csv"

    input:
    tuple val(sample_id), path(mlst_json)

    output:
    tuple val(sample_id), path("${sample_id}_alleles.csv")

    script:
    """
    parse_alleles.py -s ${sample_id} ${mlst_json} > ${sample_id}_alleles.csv
    """
}

