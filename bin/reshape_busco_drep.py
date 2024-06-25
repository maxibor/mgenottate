#!/usr/bin/env python3

import pandas as pd
from pathlib import Path
import sys

def reshape_df(df):
    basename = Path(df).stem
    df = pd.read_table(df)
    df = df[['Input_file','Complete','Duplicated']]
    df.rename(columns = {
        'Input_file':'genome',
        'Complete':'completeness',
        'Duplicated':'contamination'
        }, inplace = True)
    df.to_csv(f'{basename}_genomeInformation.csv', index=False)

if __name__ == "__main__":
    reshape_df(sys.argv[1])
