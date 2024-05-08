#!/bin/bash

artifacts_dir="artifacts"

echo "Prepare artifacts .." >> ${artifacts_dir}/test.log

mkdir -p ${artifacts_dir}/assemblies

cp -r .github/data/assemblies/* ${artifacts_dir}/assemblies

mkdir -p ${artifacts_dir}/pipeline_outputs

mv .github/data/test_output/* ${artifacts_dir}/pipeline_outputs
