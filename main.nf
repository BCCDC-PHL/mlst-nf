#!/usr/bin/env nextflow

import java.time.LocalDateTime

nextflow.enable.dsl = 2

include { hash_files } from './modules/hash_files.nf'
include { pipeline_provenance } from './modules/provenance.nf'
include { collect_provenance } from './modules/provenance.nf'
include { mlst } from './modules/mlst.nf'


workflow {
  ch_start_time = Channel.of(LocalDateTime.now())
  ch_pipeline_name = Channel.of(workflow.manifest.name)
  ch_pipeline_version = Channel.of(workflow.manifest.version)

  ch_pipeline_provenance = pipeline_provenance(ch_pipeline_name.combine(ch_pipeline_version).combine(ch_start_time))

  if (params.samplesheet_input != 'NO_FILE') {
    ch_assemblies = Channel.fromPath(params.samplesheet_input).splitCsv(header: true).map{ it -> [it['ID'], it['ASSEMBLY']] }
  } else {
    ch_assemblies = Channel.fromPath( params.assembly_search_path ).map{ it -> [it.baseName.split('_')[0], it] }.unique{ it -> it[0] }  
  }
  

  main:
  hash_files(ch_assemblies.combine(Channel.of("assembly-input")))
  mlst(ch_assemblies)

  ch_provenance = mlst.out.provenance
  ch_provenance = ch_provenance.join(hash_files.out.provenance).map{ it -> [it[0], [it[1]] << it[2]] }
  ch_provenance = ch_provenance.join(ch_assemblies.map{ it -> it[0] }.combine(ch_pipeline_provenance)).map{ it -> [it[0], it[1] << it[2]] }
  collect_provenance(ch_provenance)
  
}
