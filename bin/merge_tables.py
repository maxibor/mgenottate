#!/usr/bin/env python3

import pandas as pd
import argparse

def merge_tables(drep_genome_info, mmseqs_taxo, sample_name):
    """
    Merge the output of drep genome_info and GTDB taxonomy tables
    """

    mmseqs = pd.read_table(mmseqs_taxo, names=['genome', 'taxid', 'rank', 'name'], sep='\t')
    drep = pd.read_csv(drep_genome_info)
    merged = mmseqs.merge(drep, on='genome', how='inner')

    merged.to_csv(f"{sample_name}_mgenottate_info.csv", sep=',', index=False)


def main():
    parser = argparse.ArgumentParser(description='Merge tables')
    parser.add_argument('--drep_genome_info', type=str, help='Path to drep genome_info table')
    parser.add_argument('--mmseqs_taxo', type=str, help='Path to GTDB taxonomy table')
    parser.add_argument('--sample_name', type=str, help='Name of the sample')
    args = parser.parse_args()

    merge_tables(args.drep_genome_info, args.mmseqs_taxo, args.sample_name)


if __name__ == "__main__":
    main()