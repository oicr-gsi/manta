#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

# Jenkins seems to have different locale, so file ordering is off. Set it explicitly
export LC_ALL=en_US.utf8

#enter the workflow's final output directory ($1)
cd $1

#find all files, return their md5sums to std out
for i in *.vcf.gz; do   zcat "$i" | grep -vE "(##cmdline|##fileDate)" | md5sum; done
cat alignmentStatsSummary.txt | grep -v group | md5sum
cat svCandidateGenerationStats.tsv  | grep -vE "(SecsPer|Hours)" | md5sum
cat svLocusGraphStats.tsv |  grep -vE "(Time|Source)" | md5sum
