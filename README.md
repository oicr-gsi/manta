# manta

Manta calls structural variants (SVs) and indels from mapped paired-end sequencing reads. It is optimized for analysis of germline variation in small sets of individuals and somatic variation in tumor/normal sample pairs. Manta discovers, assembles and scores large-scale SVs, medium-sized indels and large insertions within a single efficient workflow.

## Overview

## Dependencies

* [illumina-manta 1.6.0](https://github.com/Illumina/manta/)
* [hg19 p13](https://genome.ucsc.edu/cgi-bin/hgGateway)
* [python 2.7](https://www.python.org/download/releases/2.7/)


## Usage

### Cromwell
```
java -jar cromwell.jar run manta.wdl --inputs inputs.json
```

### Inputs

#### Required workflow parameters:
Parameter|Value|Description
---|---|---
`exome`|Boolean|Set options for WES input: turn off depth filters
`rna`|Boolean|Set options for RNA-Seq input. Must specify exactly one bam input file
`unstrandedRNA`|Boolean|Set if RNA-Seq input is unstranded: Allows splice- junctions on either strand
`referenceModule`|String|Modulator module that loads the reference fasta data
`referenceFasta`|String|Name of the fasta file used as reference


#### Optional workflow parameters:
Parameter|Value|Default|Description
---|---|---|---
`normalBam`|Array[File]|[]|Normal sample BAM or CRAM file. May be specified more than once, multiple inputs will be treated as each BAM file representing a different sample. If no tumorBam is supplied, will run germline analysis. Otherwise will run somatic analysis
`normalBai`|Array[File]|[]|Index file for normalBam
`tumorBam`|File?|None|Tumor sample BAM or CRAM file. Only up to one tumor bam file accepted. If no normalBam specified, runs tumor only analysis. If one normalBam specified, runs somatic analysis. Otherwise error
`tumorBai`|File?|None|Index file for tumorBam
`callRegionsFile`|File?|None|Optionally provide a bgzip-compressed/tabix-indexed BED file containing the set of regions to call. No VCF output will be provided outside of these regions. The full genome will still be used to estimate statistics from the input (such as expected fragment size distribution). Only one BED file may be specified.


#### Optional task parameters:
Parameter|Value|Default|Description
---|---|---|---
`runManta.threads`|Int|6|Requested CPU threads
`runManta.jobMemory`|Int|16|Memory (GB) allocated for this job
`runManta.timeout`|Int|6|Number of hours before task timeout
`runManta.modules`|String|"illumina-manta/1.6.0 ~{referenceModule} python/2.7"|Module needed to run manta


### Outputs

Output | Type | Description
---|---|---
`outputVcfCandidateSV`|File|Unscored SV and indel candidates. Only a minimal amount of supporting evidence is required for an SV to be entered as a candidate in this file.
`ouputTbiCandidateSV`|File|Index file for vcf
`outputVcfCandidateSmallIndels`|File|Subset of the candidateSV.vcf.gz file containing only simple insertion and deletion variants less than the minimum scored variant size (50 by default)
`outputTbiCandidateSmallIndels`|File|Index file for vcf
`outputVcfTumorSV`|File?|If only tumor bam if specified. Subset of the candidateSV.vcf.gz file after removing redundant candidates and small indels less than the minimum scored variant size (50 by default).
`outputTbiTumorSV`|File?|Index file for vcf
`outputVcfDiploidSV`|File?|SVs and indels scored and genotyped under a diploid model for the set of samples in a joint diploid sample analysis or for the normal sample in a tumor/normal subtraction analysis. In the case of a tumor/normal subtraction, the scores in this file do not reflect any information from the tumor sample.
`outputTbiDiploidSV`|File?|Index file for vcf
`outputVcfSomaticSV`|File?|SVs and indels scored under a somatic variant model. This file will only be produced if a tumor sample alignment file is supplied during configuration
`outputTbiSomaticSV`|File?|Index file for vcf
`outputAlignmentStatsSummary`|File|fragment length quantiles for each input alignment file
`outputSvCandidateGenerationStatsTSV`|File|statistics and runtime information pertaining to the SV candidate generation
`outputSvCandidateGenerationStatsXML`|File|xml data backing the svCandidateGenerationStats.tsv report
`outputSvLocusGraphStats`|File|statistics and runtime information pertaining to the SV locus graph


## Commands
 
 This section lists command(s) run by manta workflow
 
 * Running manta
 
 Manta is a SV calling tool wrapped in a workflow which configures and then launches manta
 
 ```
    configManta.py BAM_FLAG NORMAL_BAM(s) 
                   TUMOR_BAM
                   EXOME_FLAG 
                   RNA_FLAG
                   UNSTRANDED_FLAG 
                   --referenceFasta REF_FASTA 
                   --runDir . CALL_REGIONS_COMMAND
     
    python runWorkflow.py
 
 ```
 ## Support

For support, please file an issue on the [Github project](https://github.com/oicr-gsi) or send an email to gsi@oicr.on.ca .

_Generated with generate-markdown-readme (https://github.com/oicr-gsi/gsi-wdl-tools/)_
