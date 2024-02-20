#!/bin/bash

mkdir -p .github/data/assemblies

curl -o .github/data/assemblies/NC-000913.3.fa "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?retmode=text&id=NC_000913.3&db=nucleotide&rettype=fasta"
curl -o .github/data/assemblies/NC-016845.1.fa "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?retmode=text&id=NC_016845.1&db=nucleotide&rettype=fasta"
curl -o .github/data/assemblies/NZ-LR890181.1.fa "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?retmode=text&id=NZ_LR890181.1&db=nucleotide&rettype=fasta"
