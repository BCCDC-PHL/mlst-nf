#!/bin/bash

set -eo pipefail

nextflow run main.nf \
	 -profile "${PROFILE}" \
	 --assembly_input .github/data/assemblies \
	 --outdir .github/data/test_output \
	 --collect_outputs \
	 --collected_outputs_prefix test \
	 -with-report .github/data/test_output/nextflow_report.html \
 	 -with-trace .github/data/test_output/nextflow_trace.tsv
