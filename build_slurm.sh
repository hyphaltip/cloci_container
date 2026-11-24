#!/usr/bin/env bash
#SBATCH -p epyc -n 1 -c 8 --mem=32G -t 04:00:00 -J cloci_sif -o build.log -e build.err
cd "${SLURM_SUBMIT_DIR:?submit with sbatch from the repo directory}"
./pull_sif.sh --build
