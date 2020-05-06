version 1.0 
workflow manta {
  input {
      Array[File] normalBam = []
      Array[File] normalBai = []
      File? tumorBam
      File? tumorBai
      Boolean exome
      Boolean rna
      Boolean unstrandedRNA
      File? callRegionsFile
      String referenceModule
      String referenceFasta
  }

  parameter_meta {
    normalBam: "Normal sample BAM or CRAM file. May be specified more than once, multiple inputs will be treated as each BAM file representing a different sample. If no tumorBam is supplied, will run germline analysis. Otherwise will run somatic analysis"
    normalBai: "Index file for normalBam"
    tumorBam: "Tumor sample BAM or CRAM file. Only up to one tumor bam file accepted. If no normalBam specified, runs tumor only analysis. If one normalBam specified, runs somatic analysis. Otherwise error"
    tumorBai: "Index file for tumorBam"
    exome: "Set options for WES input: turn off depth filters"
    rna: "Set options for RNA-Seq input. Must specify exactly one bam input file"
    unstrandedRNA: "Set if RNA-Seq input is unstranded: Allows splice- junctions on either strand"
    callRegionsFile: "Optionally provide a bgzip-compressed/tabix-indexed BED file containing the set of regions to call. No VCF output will be provided outside of these regions. The full genome will still be used to estimate statistics from the input (such as expected fragment size distribution). Only one BED file may be specified."
    referenceModule: "Modulator module that loads the reference fasta data"
    referenceFasta: "Name of the fasta file used as reference"
    }

  call runManta {
    input:
      normalBam = normalBam,
      normalBai = normalBai,
      tumorBam = tumorBam,
      tumorBai = tumorBai,
      exome = exome,
      rna = rna,
      unstrandedRNA = unstrandedRNA,
      callRegionsFile = callRegionsFile,
      referenceModule = referenceModule,
      referenceFasta = referenceFasta,
   }


  meta {
    author: "Savo Lazic"
    email: "savo.lazic@oicr.on.ca"
    description: "Manta calls structural variants (SVs) and indels from mapped paired-end sequencing reads. It is optimized for analysis of germline variation in small sets of individuals and somatic variation in tumor/normal sample pairs. Manta discovers, assembles and scores large-scale SVs, medium-sized indels and large insertions within a single efficient workflow."
    dependencies: 
    [
      {
      name: "illumina-manta/1.6.0",
      url: "https://github.com/Illumina/manta/"
      },
      {
      name: "hg19/p13",
      url: "https://genome.ucsc.edu/cgi-bin/hgGateway"
      },
      {
      name: "python/2.7",
      url: "https://www.python.org/download/releases/2.7/"
      }
    ]
    output_meta: {
      outputVcfCandidateSV: "Unscored SV and indel candidates. Only a minimal amount of supporting evidence is required for an SV to be entered as a candidate in this file.",
      outputTbiCandidateSV: "Index file for vcf",
      outputVcfCandidateSmallIndels: "Subset of the candidateSV.vcf.gz file containing only simple insertion and deletion variants less than the minimum scored variant size (50 by default)",
      outputTbiCandidateSmallIndels: "Index file for vcf",
      outputVcfTumorSV: "If only tumor bam if specified. Subset of the candidateSV.vcf.gz file after removing redundant candidates and small indels less than the minimum scored variant size (50 by default)." ,
      outputTbiTumorSV: "Index file for vcf",
      outputVcfDiploidSV: "SVs and indels scored and genotyped under a diploid model for the set of samples in a joint diploid sample analysis or for the normal sample in a tumor/normal subtraction analysis. In the case of a tumor/normal subtraction, the scores in this file do not reflect any information from the tumor sample.",
      outputTbiDiploidSV: "Index file for vcf",
      outputVcfSomaticSV: "SVs and indels scored under a somatic variant model. This file will only be produced if a tumor sample alignment file is supplied during configuration",
      outputTbiSomaticSV: "Index file for vcf",
      outputAlignmentStatsSummary: "fragment length quantiles for each input alignment file",
      outputSvCandidateGenerationStatsTSV: "statistics and runtime information pertaining to the SV candidate generation",
      outputSvCandidateGenerationStatsXML: "xml data backing the svCandidateGenerationStats.tsv report",
      outputSvLocusGraphStats: "statistics and runtime information pertaining to the SV locus graph"
    }
  }
  output {
    File outputVcfCandidateSV = runManta.vcfCandidateSV
    File ouputTbiCandidateSV = runManta.tbiCandidateSV
    File outputVcfCandidateSmallIndels = runManta.vcfCandidateSmallIndels
    File outputTbiCandidateSmallIndels = runManta.tbiCandidateSmallIndels
    File? outputVcfTumorSV = runManta.vcfTumorSV
    File? outputTbiTumorSV = runManta.tbiTumorSV
    File? outputVcfDiploidSV = runManta.vcfDiploidSV
    File? outputTbiDiploidSV = runManta.tbiDiploidSV
    File? outputVcfSomaticSV = runManta.vcfSomaticSV
    File? outputTbiSomaticSV = runManta.tbiSomaticSV
    File outputAlignmentStatsSummary = runManta.alignmentStatsSummary
    File outputSvCandidateGenerationStatsTSV = runManta.svCandidateGenerationStatsTSV
    File outputSvCandidateGenerationStatsXML = runManta.svCandidateGenerationStatsXML
    File outputSvLocusGraphStats = runManta.svLocusGraphStats
  }
}

task runManta {
  input {
    Array[File] normalBam
    Array[File] normalBai
    File? tumorBam
    File? tumorBai
    Boolean exome
    Boolean rna
    Boolean unstrandedRNA
    File? callRegionsFile
    String referenceModule
    String referenceFasta
    Int threads = 6
    Int jobMemory = 16
    Int timeout = 6
    String modules = "illumina-manta/1.6.0 ~{referenceModule} python/2.7"
  }

  parameter_meta {
    normalBam: "Normal sample BAM or CRAM file. May be specified more than once, multiple inputs will be treated as each BAM file representing a different sample. If no tumorBam is supplied, will run germline analysis. Otherwise will run somatic analysis"
    normalBai: "Index file for normalBam"
    tumorBam: "Tumor sample BAM or CRAM file. Only up to one tumor bam file accepted. If no normalBam specified, runs tumor only analysis. If one normalBam specified, runs somatic analysis. Otherwise error"
    tumorBai: "Index file for tumorBam"
    exome: "Set options for WES input: turn off depth filters"
    rna: "Set options for RNA-Seq input. Must specify exactly one bam input file"
    unstrandedRNA: "Set if RNA-Seq input is unstranded: Allows splice- junctions on either strand"
    callRegionsFile: "Optionally provide a bgzip-compressed/tabix-indexed BED file containing the set of regions to call. No VCF output will be provided outside of these regions. The full genome will still be used to estimate statistics from the input (such as expected fragment size distribution). Only one BED file may be specified."
    referenceModule: "Modulator module that loads the reference fasta data"
    referenceFasta: "Name of the fasta file used as reference"
    modules: "Module needed to run manta"
    jobMemory: "Memory (GB) allocated for this job"
    threads: "Requested CPU threads"
    timeout: "Number of hours before task timeout"
    }

  String bamFlag = if length(normalBam) > 0 then "--bam " else ""
  String tumorBamCommand = if defined(tumorBam) then "--tumorBam ~{tumorBam}" else ""
  String exomeCommand = if exome then "--exome" else ""
  String rnaCommand = if rna then "--rna" else ""
  String unstrandedRNACommand = if unstrandedRNA then "--unstrandedRNA" else ""
  String callRegionsCommand = if defined(callRegionsFile) then "--callregions ~{callRegionsFile}" else ""


  command <<<
    set -euo pipefail
    configManta.py ~{bamFlag} ~{sep = " --bam " normalBam} ~{tumorBamCommand} ~{exomeCommand} ~{rnaCommand} ~{unstrandedRNACommand} --referenceFasta "~{referenceFasta}" --runDir . ~{callRegionsCommand};
    python2.7 runWorkflow.py;
  >>>

  output {
    File vcfCandidateSV = "./results/variants/candidateSV.vcf.gz"
    File tbiCandidateSV = "./results/variants/candidateSV.vcf.gz.tbi"
    File vcfCandidateSmallIndels = "./results/variants/candidateSmallIndels.vcf.gz"
    File tbiCandidateSmallIndels = "./results/variants/candidateSmallIndels.vcf.gz.tbi"
    File? vcfTumorSV = "./results/variants/tumorSV.vcf.gz"
    File? tbiTumorSV = "./results/variants/tumorSV.vcf.gz.tbi"
    File? vcfDiploidSV = "./results/variants/diploidSV.vcf.gz"
    File? tbiDiploidSV = "./results/variants/diploidSV.vcf.gz.tbi"
    File? vcfSomaticSV = "./results/variants/somaticSV.vcf.gz"
    File? tbiSomaticSV = "./results/variants/somaticSV.vcf.gz.tbi"
    File alignmentStatsSummary = "./results/stats/alignmentStatsSummary.txt"
    File svCandidateGenerationStatsTSV = "./results/stats/svCandidateGenerationStats.tsv"
    File svCandidateGenerationStatsXML = "./results/stats/svCandidateGenerationStats.xml"
    File svLocusGraphStats = "./results/stats/svLocusGraphStats.tsv"
  }

  meta {
    output_meta: {
      vcfCandidateSV: "Unscored SV and indel candidates. Only a minimal amount of supporting evidence is required for an SV to be entered as a candidate in this file.",
      tbiCandidateSV: "Index file for vcf",
      vcfCandidateSmallIndels: "Subset of the candidateSV.vcf.gz file containing only simple insertion and deletion variants less than the minimum scored variant size (50 by default)",
      tbiCandidateSmallIndels: "Index file for vcf",
      vcfTumorSV: "If only tumor bam if specified. Subset of the candidateSV.vcf.gz file after removing redundant candidates and small indels less than the minimum scored variant size (50 by default)." ,
      tbiTumorSV: "Index file for vcf",
      vcfDiploidSV: "SVs and indels scored and genotyped under a diploid model for the set of samples in a joint diploid sample analysis or for the normal sample in a tumor/normal subtraction analysis. In the case of a tumor/normal subtraction, the scores in this file do not reflect any information from the tumor sample.",
      tbiDiploidSV: "Index file for vcf",
      vcfSomaticSV: "SVs and indels scored under a somatic variant model. This file will only be produced if a tumor sample alignment file is supplied during configuration",
      tbiSomaticSV: "Index file for vcf",
      alignmentStatsSummary: "fragment length quantiles for each input alignment file",
      svCandidateGenerationStatsTSV: "statistics and runtime information pertaining to the SV candidate generation",
      svCandidateGenerationStatsXML: "xml data backing the svCandidateGenerationStats.tsv report",
      svLocusGraphStats: "statistics and runtime information pertaining to the SV locus graph"
    }
  }

  runtime {
    modules: "~{modules}"
    memory:  "~{jobMemory} GB"
    cpu:     "~{threads}"
    timeout: "~{timeout}"
  }
}
