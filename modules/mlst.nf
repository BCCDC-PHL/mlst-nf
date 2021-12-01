process mlst {

    tag { sample_id }

    publishDir "${params.outdir}/${sample_id}", mode: 'copy', pattern: "${sample_id}_mlst.csv"

    input:
    tuple val(sample_id), path(assembly)

    output:
    tuple val(sample_id), path("${sample_id}_mlst.csv"), emit: csv
    tuple val(sample_id), path("${sample_id}_mlst_provenance.yml"), emit: provenance
    
    script:
    """
    printf -- "- tool_name: mlst\\n  tool_version: \$(mlst --version | cut -d ' ' -f 2)\\n" > ${sample_id}_mlst_provenance.yml
    mlst --csv ${assembly} > ${sample_id}_mlst.csv
    """
}
