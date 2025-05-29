#!/usr/bin/env python

import argparse
import glob
import json
import os
import subprocess


def pull_image_apptainer(image_url, destination_image_file):
    """
    """
    apptainer_pull_cmd = [
        "apptainer",
        "pull",
        destination_image_file,
        image_url,
    ]
    subprocess.run(apptainer_pull_cmd)


def pull_image_docker(image_url):
    """
    """
    docker_pull_cmd = [
        "docker",
        "pull",
        image_url
    ]
    subprocess.run(docker_pull_cmd)


def push_image_apptainer(source_image_file, image_url):
    """
    """

    apptainer_push_cmd = [
        "apptainer",
        "push",
        source_image_file,
        image_url,
    ]
    subprocess.run(apptainer_push_cmd)


def tag_image_docker(source_image_url, dest_image_url):
    """
    """
    docker_tag_cmd = [
        "docker",
        "tag",
        source_image_url,
        dest_image_url
    ]
    subprocess.run(docker_tag_cmd)
    

def push_image_docker(image_url):
    """
    """
    docker_push_cmd = [
        "docker",
        "push",
        image_url,
    ]
    subprocess.run(docker_push_cmd)

    

def main(args):
    repo_owner = os.environ['GITHUB_REPOSITORY_OWNER'].lower()
    
    wave_jsons = glob.glob(os.path.join(args.wave_jsons_dir, "*.json"))
    for wave_json in wave_jsons:
        container_is_apptainer = False
        with open(wave_json, 'r') as f:
            w = json.load(f)
            pull_image_url = w['containerImage']
            image_name_with_version = pull_image_url.split('/')[-1]
            image_name, image_version = image_name_with_version.split(':')
            push_image_url = f"ghcr.io/{repo_owner}/{image_name}:{image_version}"

            if pull_image_url.startswith("oras://"):
                container_is_apptainer = True
            

            if container_is_apptainer:
                push_image_url = "oras://" + push_image_url
                pull_destination = os.path.join(args.images_dir, f"{image_name}--{image_version}.img")
                pull_image_apptainer(pull_image_url, pull_destination)
                push_image_apptainer(pull_destination, push_image_url)
            else:
                pull_image_docker(pull_image_url)
                tag_image_docker(pull_image_url, push_image_url)
                push_image_docker(push_image_url)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--wave-jsons-dir')
    parser.add_argument('--images-dir')
    args = parser.parse_args()
    main(args)
