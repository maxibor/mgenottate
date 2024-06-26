

# maxibor/mgenottate

```mermaid
graph LR
    a[genome fasta]--> b[busco quality assesment]
    b --> c[dRep genome ANI dereplication]
    c --> d[MMSeqs2 genome taxonomic_annotation]
    d --> e[Summary table]
```

## Usage

```bash
nextflow run maxibor/mgenottate -profile {conda,docker,singularity} --input genome_sheet.csv --busco_db path/to/busco/db --mmseqs2_db_path path/to/mmseqs/db
```

## Input/output options                                                                                                            
                                                                                                                                   
Define where the pipeline should find input data and save output data.                                                             
                                                                                                                                   
| Parameter | Description | Type | Default | Required | Hidden |                                                                   
|-----------|-----------|-----------|-----------|-----------|-----------|                                                          
| `input` | Path to comma-separated file containing information about the samples and genomes See below for more infos. | `string` |  | True |  |                                                                             
| `outdir` | The output directory where the results will be saved. You have to use absolute paths to storage on Cloud                                                                                           


> An example input file can be found in [tests/data/test_samplesheet.csv](tests/data/test_samplesheet.csv)

It contains 2 columns, the first one being the sample name to which a genome belog, and the second one the path to a genome in fasta file (compressed or not).

## Databases                                                                                                                                                                                                                                 
| Parameter | Description | Type | Default | Required | Hidden |                                                                   
|-----------|-----------|-----------|-----------|-----------|-----------|                                                          
| `busco_db` | Path to busco database | `string` |  | True |  |                                                                    
| `mmseqs2_db_name` | Name of mmseqs prebuilt database (required if not db path is provided) <details><summary>Help</summary><small>See                                  
https://github.com/soedinglab/MMseqs2/wiki#downloading-databases </small></details>| `string` |  |  |  |                            
| `mmseqs2_db_path` | Path to mmseqs database (required if no db name is provided)| `string` |  |  |  |                                                                
                                                                                                                                   
## Tools options

| Parameter | Description | Type | Default | Required | Hidden |                                                                   
|-----------|-----------|-----------|-----------|-----------|-----------|                                                          
| `busco_mode` | Busco mode <details><summary>Help</summary><small>One of genome, proteins, or transcriptome</small></details>|    
`string` | genome |  |  |                                                                                                          
| `busco_lineage` | Busco lineage. auto for automatic lineage selection | `string` | auto |  |  |                                  
| `drep_ani` | drep secondary clustering ANI threshold | `number` | 0.99 |  |  |                                                   
| `mmseqs_search_type` | 2 (translated), 3 (nucleotide) or 4 (translated 
nucleotide backtrace | `integer` | 3 |  |  |                                                        

## Max job request options                                                                                                         
                                                                                                                                   
Set the top limit for requested resources for any single job.                                                                      
                                                                                                                                   
| Parameter | Description | Type | Default | Required | Hidden |                                                                   
|-----------|-----------|-----------|-----------|-----------|-----------|                                                          
| `max_cpus` | Maximum number of CPUs that can be requested for any single job. <details><summary>Help</summary><small>Use to set  
an upper-limit for the CPU requirement for each process. Should be an integer e.g. `--max_cpus 1`</small></details>| `integer` | 16
|  | True |                                                                                                                        
| `max_memory` | Maximum amount of memory that can be requested for any single job. <details><summary>Help</summary><small>Use to  
set an upper-limit for the memory requirement for each process. Should be a string in the format integer-unit e.g. `--max_memory   
'8.GB'`</small></details>| `string` | 128.GB |  | True |                                                                           
| `max_time` | Maximum amount of time that can be requested for any single job. <details><summary>Help</summary><small>Use to set  
an upper-limit for the time requirement for each process. Should be a string in the format integer-unit e.g. `--max_time           
'2.h'`</small></details>| `string` | 240.h |  | True |                                                                             
                                                                                                                                   
## Generic options                                                                                                                 
                                                                                                                                   
Less common options for the pipeline, typically set in a config file.                                                              
                                                                                                                                   
| Parameter | Description | Type | Default | Required | Hidden |                                                                   
|-----------|-----------|-----------|-----------|-----------|-----------|                                                          
| `help` | Display help text. | `boolean` |  |  | True |                                                                           
| `version` | Display version and exit. | `boolean` |  |  | True |                                                                 
| `publish_dir_mode` | Method used to save pipeline results to output directory. <details><summary>Help</summary><small>The        
Nextflow `publishDir` option specifies which intermediate files should be saved to the output directory. This option tells the     
pipeline what method should be used to move these files. See [Nextflow                                                             
docs](https://www.nextflow.io/docs/latest/process.html#publishdir) for details.</small></details>| `string` | copy |  | True |     
| `monochrome_logs` | Do not use coloured log outputs. | `boolean` |  |  | True |                                                  
                                                                                                                                   


