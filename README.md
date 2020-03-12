# manta

Medips

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


#### Optional workflow parameters:
Parameter|Value|Default|Description
---|---|---|---
`normalBam`|Array[String]?|None|
`normalBai`|Array[File]?|None|
`tumorBam`|File?|None|
`tumorBai`|File?|None|
`referenceFasta`|String|"{HG19_ROOT}/hg19_random.fa"|
`exome`|Boolean?|None|
`rna`|Boolean?|None|
`unstrandedRNA`|Boolean?|None|
`callRegionsFile`|File?|None|


#### Optional task parameters:
Parameter|Value|Default|Description
---|---|---|---
`configManta.threads`|Int|6|Requested CPU threads
`configManta.jobMemory`|Int|16|Memory (GB) allocated for this job
`configManta.timeout`|Int|6|Number of hours before task timeout
`configManta.modules`|String|"illumina-manta/1.6.0 hg19/p13 python/2.7"|Module needed to run manta


### Outputs

Output | Type | Description
---|---|---
`outputVcfFiles`|Array[File]|All VCF files
`outputTbiFiles`|Array[File]|All TBI Files
`outputAlignmentStatsSummary`|File|Summary of alignment stats
`outputSvCandidateGenerationStatsTSV`|File|TSV stats
`outputSvCandidateGenerationStatsXML`|File|XML stats
`outputSvLocusGraphStats`|File|Locus graph for structural variants


## Niassa + Cromwell

This WDL workflow is wrapped in a Niassa workflow (https://github.com/oicr-gsi/pipedev/tree/master/pipedev-niassa-cromwell-workflow) so that it can used with the Niassa metadata tracking system (https://github.com/oicr-gsi/niassa).

* Building
```
mvn clean install
```

* Testing
```
mvn clean verify \
-Djava_opts="-Xmx1g -XX:+UseG1GC -XX:+UseStringDeduplication" \
-DrunTestThreads=2 \
-DskipITs=false \
-DskipRunITs=false \
-DworkingDirectory=/path/to/tmp/ \
-DschedulingHost=niassa_oozie_host \
-DwebserviceUrl=http://niassa-url:8080 \
-DwebserviceUser=niassa_user \
-DwebservicePassword=niassa_user_password \
-Dcromwell-host=http://cromwell-url:8000
```

## Support

For support, please file an issue on the [Github project](https://github.com/oicr-gsi) or send an email to gsi@oicr.on.ca .

_Generated with wdl_doc_gen (https://github.com/oicr-gsi/wdl_doc_gen/)_

