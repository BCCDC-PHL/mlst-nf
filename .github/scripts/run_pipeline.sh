#!/bin/bash

set -eo pipefail

nextflow run main.nf \
	 -profile conda \
	 --cache ${HOME}/.conda/envs \
	 --assembly_input .github/data/assemblies \
	 --outdir .github/data/test_output \
	 -with-report .github/data/test_output/nextflow_report.html \
 	 -with-trace .github/data/test_output/nextflow_trace.tsv
