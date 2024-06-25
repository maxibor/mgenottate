#!/usr/bin/env python3

import textwrap
import pysam
import os
import sys
import logging

def contig_concat(fa):
    """
    Concat all contigs in a fasta file into a single sequence
    """

    linker = "NNNNNCATTCCATTCATTAATTAATTAATGAATGAATGNNNNN"
    fname = os.path.basename(fa)
    genseq = []

    logging.info(f"Reading {fa}")
    with pysam.FastxFile(fa) as fasta:
        for contig in fasta:
            genseq.append(contig.sequence)

    genseq = linker.join(genseq)

    logging.info(f"Writing {fname}")
    with open(fname, "w") as out:
        out.write(f">{fname}\n")
        for line in textwrap.wrap(genseq, 80):
            out.write(line + "\n")
            
if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    contig_concat(sys.argv[1])