#!/usr/bin/env nextflow

import java.time.LocalDateTime

nextflow.enable.dsl = 2

include { hash_files }             from './modules/hash_files.nf'
include { pipeline_provenance }    from './modules/provenance.nf'
include { collect_provenance }     from './modules/provenance.nf'
include { quast }                  from './modules/quast.nf'
include { parse_quast_report }     from './modules/quast.nf'
include { mlst }                   from './modules/mlst.nf'
include { parse_alleles }          from './modules/mlst.nf'

workflow {

    ch_workflow_metadata = Channel.value([
        workflow.sessionId,
        workflow.runName,
        workflow.manifest.name,
        workflow.manifest.version,
        workflow.start,
    ])

    if (params.samplesheet_input != 'NO_FILE') {
	      ch_assemblies = Channel.fromPath(params.samplesheet_input).splitCsv(header: true).map{ it -> [it['ID'], it['ASSEMBLY']] }
    } else {
	      ch_assemblies = Channel.fromPath( params.assembly_search_path ).map{ it -> [it.baseName.split('_')[0], it] }.unique{ it -> it[0] }  
    }

    main:
    hash_files(ch_assemblies.combine(Channel.of("assembly-input")))
    quast(ch_assemblies)
    parse_quast_report(quast.out.tsv)
    mlst(ch_assemblies)
    parse_alleles(mlst.out.mlst)

    if (params.collect_outputs) {
        parse_quast_report.out.map{ it -> it[1] }.collectFile(
        name: params.collected_outputs_prefix + "_quast.csv",
                  storeDir: params.outdir,
                  keepHeader: true,
                  sort: { it -> it.readLines()[1].split(',')[0] }
              )
              parse_alleles.out.alleles.map{ it -> it[1] }.collectFile(
                  name: params.collected_outputs_prefix + "_alleles.csv",
                  storeDir: params.outdir,
                  keepHeader: true,
                  sort: { it -> it.readLines()[1].split(',')[0] }
              )
              parse_alleles.out.sequence_type.map{ it -> it[1] }.collectFile(
                  name: params.collected_outputs_prefix + "_sequence_type.csv",
                  storeDir: params.outdir,
                  keepHeader: true,
                  sort: { it -> it.readLines()[1].split(',')[0] }
              )
    }

    ch_sample_ids = ch_assemblies.map{ it -> it[0] }
    ch_provenance = ch_sample_ids
    ch_pipeline_provenance = pipeline_provenance(ch_workflow_metadata)
    ch_provenance = ch_provenance.combine(ch_pipeline_provenance).map{ it -> [it[0], [it[1]]] }
    ch_provenance = ch_provenance.join(hash_files.out.provenance).map{ it -> [it[0], it[1] << it[2]] }
    ch_provenance = ch_provenance.join(mlst.out.provenance).map{ it ->       [it[0], it[1] << it[2]] }
    ch_provenance = ch_provenance.join(quast.out.provenance).map{ it ->      [it[0], it[1] << it[2]] }

    collect_provenance(ch_provenance)
}
