#!/usr/bin/env python3

import argparse
import csv
import glob
import json
import urllib.request

from jsonschema import validate
import yaml


def check_provenance_format_valid(provenance_files, schema):
    """
    Check that the provenance files are valid according to the schema.
    """
    for provenance_file in provenance_files:
        with open(provenance_file) as f:
            try:
                provenance = yaml.load(f, Loader=yaml.BaseLoader)
                validate(provenance, schema)
            except Exception as e:
                return False

    return True


def check_expected_sequence_types(sequence_type_files, expected_sequence_types_by_sample_id):
    """
    Check that the sequence types are as expected.

    :param sequence_type_files: Sequence type files
    :type sequence_type_files: list[str]
    :param expected_sequence_types_by_sample_id: Expected sequence types by sample ID
    :type expected_sequence_types_by_sample_id: dict[str, dict[str, str]]
    :return: True if the sequence types are as expected, False otherwise
    """
    sequence_type_by_sample = {}
    for sequence_type_file in sequence_type_files:
        with open(sequence_type_file) as f:
            reader = csv.DictReader(f)
            for row in reader:
                sample_id = row['sample_id']
                scheme = row['scheme']
                sequence_type = row['sequence_type']
                sequence_type_by_sample[sample_id] = {
                    "scheme": scheme,
                    "sequence_type": sequence_type
                }

    for sample_id, expected_sequence_type in expected_sequence_types_by_sample_id.items():
        if sample_id not in sequence_type_by_sample:
            return False
        if expected_sequence_type['scheme'] != sequence_type_by_sample[sample_id]['scheme']:
            return False
        if expected_sequence_type['sequence_type'] != sequence_type_by_sample[sample_id]['sequence_type']:
            return False

    return True


def parse_expected_sequence_type(expected_sequence_types_path):
    """
    Parse the expected sequence types CSV file.
    
    :param expected_sequence_types_path: Path to the expected sequence types CSV file
    :type expected_sequence_types_path: str
    :return: Expected sequence type by sample ID
    :rtype: dict[str, dict[str, str]]
    """
    expected_sequence_type_by_sample_id = {}
    with open(expected_sequence_types_path) as f:
        reader = csv.DictReader(f)
        for row in reader:
            sample_id = row['sample_id']
            expected_sequence_type_by_sample_id[sample_id] = row

    return expected_sequence_type_by_sample_id


def main(args):
    provenance_schema_url = "https://raw.githubusercontent.com/BCCDC-PHL/pipeline-provenance-schema/main/schema/pipeline-provenance.json"
    provenance_schema_path = ".github/data/pipeline-provenance.json"
    urllib.request.urlretrieve(provenance_schema_url, provenance_schema_path)

    provenance_schema = None
    with open(provenance_schema_path) as f:
        provenance_schema = json.load(f)

    provenace_files_glob = f"{args.pipeline_outdir}/**/*_provenance.yml"
    provenance_files = glob.glob(provenace_files_glob, recursive=True)

    sequence_type_files_glob = f"{args.pipeline_outdir}/**/*sequence_type.csv"
    sequence_type_files = glob.glob(sequence_type_files_glob, recursive=True)

    expected_sequence_type_by_sample_id = parse_expected_sequence_type(args.expected_sequence_types)

    tests = [
        {
            "test_name": "provenance_format_valid",
            "test_passed": check_provenance_format_valid(provenance_files, provenance_schema),
        },
        {
            "test_name": "expected_sequence_types",
            "test_passed": check_expected_sequence_types(sequence_type_files, expected_sequence_type_by_sample_id),
        },
    ]

    output_fields = [
        "test_name",
        "test_result"
    ]

    output_path = args.output
    with open(output_path, 'w') as f:
        writer = csv.DictWriter(f, fieldnames=output_fields, extrasaction='ignore')
        writer.writeheader()
        for test in tests:
            if test["test_passed"]:
                test["test_result"] = "PASS"
            else:
                test["test_result"] = "FAIL"
            writer.writerow(test)

    for test in tests:
        if not test['test_passed']:
            exit(1)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Check outputs')
    parser.add_argument('--pipeline-outdir', type=str, help='Path to the pipeline output directory')
    parser.add_argument('--expected-sequence-types', type=str, default='.github/data/expected_sequence_types.csv', help='Path to the expected sequence types CSV file')
    parser.add_argument('-o', '--output', type=str, help='Path to the output file')
    args = parser.parse_args()
    main(args)
