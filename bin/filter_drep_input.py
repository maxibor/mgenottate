#!/usr/bin/env python3


import argparse
import pandas as pd
from pathlib import Path


def clean_input(busco_in, busco_out, genomes_out):
    pres_genomes = [i.name for i in list(Path(".").glob("*.fa")) + list(Path(".").glob("*.fna"))]
    df = pd.read_csv(busco_in)
    df.query("genome in @pres_genomes").to_csv(busco_out, index=False)

    with open(genomes_out, "w") as f:
        for g in pres_genomes:
            if g in df.genome.values:
                f.write(g + "\n")


def main():
    parser = argparse.ArgumentParser(description='filter_drep_input')
    parser.add_argument('--busco_sum_in', type=str, help='Path to input busco_summary_table')
    parser.add_argument('--busco_sum_out', type=str, help='Path to output busco_summary_table')
    parser.add_argument('--genomes_out', type=str, help='Name of the sample')
    args = parser.parse_args()

    clean_input(args.busco_sum_in, args.busco_sum_out, args.genomes_out)

if __name__ == "__main__":
    main()
