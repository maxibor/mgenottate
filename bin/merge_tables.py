#!/usr/bin/env python3

import pandas as pd
import numpy as np
import argparse

def merge_tables(drep_genome_info, cdb, sdb, mmseqs_taxo, sample_name):
    """
    Merge the output of drep genome_info and mmseqs taxonomy tables
    """
    drep = pd.read_csv(drep_genome_info)
    format_4_cols = ['genome', 'taxid', 'rank', 'name']
    format_8_cols = [
            'genome', 
            'taxid', 
            'rank', 
            'name',
            'nb_fragments_retained',
            'nb_fragments_taxo_assigned',
            'nb_fragments_taxo_agreement',
            'taxo_support'
        ] # see https://github.com/soedinglab/MMseqs2/wiki#taxonomy-output-and-tsv
    cdb = pd.read_csv(cdb)
    sdb = pd.read_csv(sdb)
    try:
        mmseqs = pd.read_table(mmseqs_taxo, sep='\t', header=None)
        if mmseqs.shape[1] == 4:
            mmseqs.columns = format_4_cols
        elif mmseqs.shape[1] == 8:
            mmseqs.columns = format_8_cols
        merged = (
            drep
            .merge(cdb, on='genome', how='outer')
            .merge(sdb, on='genome', how='outer')
            .merge(mmseqs, on='genome', how='outer')
        )
    except pd.errors.EmptyDataError:
        merged = (
            drep
            .merge(cdb, on='genome', how='outer')
            .merge(sdb, on='genome', how='outer')
        )
    cluster_rep = (
        merged
        .groupby("secondary_cluster")
        .apply(lambda x: x.loc[x["score"].idxmax()])
        .reset_index(drop=True)
    )['genome'].to_list()
    merged['cluster_rep'] = np.where(merged['genome'].isin(cluster_rep), merged['secondary_cluster'], 'no')
    merged.to_csv(f"{sample_name}_mgenottate_info.csv", sep=',', index=False)


def main():
    parser = argparse.ArgumentParser(description='Merge tables')
    parser.add_argument('--drep_genome_info', type=str, help='Path to drep genome_info table')
    parser.add_argument('--mmseqs_taxo', type=str, help='Path to mmseqs taxonomy table')
    parser.add_argument('--sample_name', type=str, help='Name of the sample')
    parser.add_argument("--cdb", type=str, help="Path to the CDB file")
    parser.add_argument("--sdb", type=str, help="Path to the SDB file")
    args = parser.parse_args()

    merge_tables(args.drep_genome_info, args.cdb, args.sdb, args.mmseqs_taxo, args.sample_name)


if __name__ == "__main__":
    main()