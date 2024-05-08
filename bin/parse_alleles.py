#!/usr/bin/env python3

import argparse
import re
import json


def main(args):

    with open(args.mlst_json, 'r') as f:
        mlst = json.load(f)

    for sample in mlst:
        if args.sample_id:
            sample_id = args.sample_id
        else:
            sample_id = sample['id']

        print(','.join([
            'sample_id',
            'scheme',
            'locus',
            'allele',
            'perfect_match',
            'novel_allele',
            'score',
        ]))

        if not sample['alleles']:
            continue
        num_alleles = len(sample['alleles'])
        scheme = sample['scheme']
        for locus, allele in sample['alleles'].items():
            perfect_match = True
            novel_allele = False
            score = round(90 / num_alleles, 2)
            output_lines = []
            if len(allele.split(',')) > 1:
                alleles = allele.split(',')
                for allele in alleles:
                    if allele.startswith('~'):
                        perfect_match = False
                        novel_allele = True
                        score = round(63 / num_alleles, 2)
                    elif re.match('[A-Za-z0-9~?]*\?$', allele):
                        perfect_match = False
                        novel_allele = False
                        score = round(18 / num_alleles, 2)
                    output_lines.append([sample_id, scheme, locus, allele, str(perfect_match), str(novel_allele), str(score)])
                    perfect_match = True
                    novel_allele = False
                    score = round(90 / num_alleles, 2)
            elif allele.startswith('~'):
                perfect_match = False
                novel_allele = True
                score = round(63 / num_alleles, 2)
                output_lines.append([sample_id, scheme, locus, allele, str(perfect_match), str(novel_allele), str(score)])
            elif re.match('[A-Za-z0-9~?]*\?$', allele):
                perfect_match = False
                novel_allele = False
                score = round(18 / num_alleles, 2)
                output_lines.append([sample_id, scheme, locus, allele, str(perfect_match), str(novel_allele), str(score)])
            elif re.match('-$', allele):
                perfect_match = False
                novel_allele = False
                score = 0.00
                output_lines.append([sample_id, scheme, locus, allele, str(perfect_match), str(novel_allele), str(score)])
            else:
                score = round(90 / num_alleles, 2)
                output_lines.append([sample_id, scheme, locus, allele, str(perfect_match), str(novel_allele), str(score)])
            for output_line in output_lines:
                print(','.join(output_line))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-s', '--sample-id')
    parser.add_argument('mlst_json')
    args = parser.parse_args()
    main(args)
