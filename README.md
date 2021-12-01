# mlst-nf
A nextflow pipeline for running [mlst](https://github.com/tseemann/mlst) on a set of assemblies.

## Usage

```
nextflow run BCCDC-PHL/mlst-nf \
  --assembly_input </path/to/assemblies> \
  --outdir </path/to/outdir>
```

The pipeline also supports a 'samplesheet input' mode. Pass a samplesheet.csv file with the headers `ID`, `ASSEMBLY`:

```
nextflow run BCCDC-PHL/mlst-nf \
  --samplesheet_input </path/to/samplesheet.csv> \
  --outdir </path/to/outdir>
```
