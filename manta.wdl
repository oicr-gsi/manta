version 1.0 
workflow manta {
  input {
      Array[File]? normalBam
      Array[File]? normalBai
      File? tumorBam
      File? tumorBai
      Boolean exome
      Boolean rna
      Boolean unstrandedRNA
      File? callRegionsFile
      String referenceModule
      String referenceFasta
  }
   String normalBamCommand = if defined(normalBam) == true then "--bam" else ""
   String bam = if defined(normalBam) == true then "true" else "false"
   String tumorBamCommand = if defined(tumorBam) == true then "--tumorBam ~{tumorBam}" else ""
   String exomeCommand = if exome == true then "--exome" else ""
   String rnaCommand = if rna == true then "--rna" else ""
   String unstrandedRNACommand = if unstrandedRNA == true then "--unstrandedRNA" else ""
   String callRegionsCommand = if defined(callRegionsFile) == true then "--callregions ~{callRegionsFile}" else ""


  if (defined(normalBam) == true) {
    call configMantaNormal {
      input: normalBam = normalBam,
             bam = bam,
             normalBai = normalBai,
             tumorBam = tumorBam,
             tumorBai = tumorBai,
             callRegionsFile = callRegionsFile,
             referenceModule = referenceModule, 
             referenceFasta = referenceFasta,
             normalBamCommand = normalBamCommand,
             tumorBamCommand = tumorBamCommand,
             exomeCommand = exomeCommand,
             rnaCommand = rnaCommand,
             unstrandedRNACommand = unstrandedRNACommand,
             callRegionsCommand = callRegionsCommand
    }
  }


  if (defined(normalBam) == false) {
    call configMantaTumor {
      input: normalBam = normalBam,
             bam = bam,
             normalBai = normalBai,
             tumorBam = tumorBam,
             tumorBai = tumorBai,
             callRegionsFile = callRegionsFile,
             referenceModule = referenceModule,
             referenceFasta = referenceFasta,
             normalBamCommand = normalBamCommand,
             tumorBamCommand = tumorBamCommand,
             exomeCommand = exomeCommand,
             rnaCommand = rnaCommand,
             unstrandedRNACommand = unstrandedRNACommand,
             callRegionsCommand = callRegionsCommand
    }
  }
  meta {
    author: "Rishi Shah"
    email: "rshah@oicr.on.ca"
    description: "Medips"
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
      outputVcfFiles: "All VCF files",
      outputTbiFiles: "All TBI Files",
      outputAlignmentStatsSummary: "Summary of alignment stats",
      outputSvCandidateGenerationStatsTSV: "TSV stats",
      outputSvCandidateGenerationStatsXML: "XML stats",
      outputSvLocusGraphStats: "Locus graph for structural variants"
    }
  }
  output {
    File? outputVcfCandidateSV = select_first([configMantaNormal.vcfCandidateSV, configMantaTumor.vcfCandidateSV])
    File? ouputTbiCandidateSV = select_first([configMantaNormal.tbiCandidateSV, configMantaTumor.tbiCandidateSV])
    File? outputVcfCandidateSmallIndels = select_first([configMantaNormal.vcfCandidateSmallIndels, configMantaTumor.vcfCandidateSmallIndels])
    File? outputTbiCandidateSmallIndels = select_first([configMantaNormal.tbiCandidateSmallIndels, configMantaTumor.tbiCandidateSmallIndels])
    File? outputVcfTumorSV = select_first([configMantaNormal.vcfTumorSV, configMantaTumor.vcfTumorSV])
    File? outputTbiTumorSV = select_first([configMantaNormal.tbiTumorSV, configMantaTumor.tbiTumorSV])
    File? outputVcfDiploidSV = select_first([configMantaNormal.vcfDiploidSV, configMantaTumor.vcfDiploidSV])
    File? outputTbiDiploidSV = select_first([configMantaNormal.tbiDiploidSV, configMantaTumor.tbiDiploidSV])
    File? outputVcfSomaticSV = select_first([configMantaNormal.vcfSomaticSV, configMantaTumor.vcfSomaticSV])
    File? outputTbiSomaticSV = select_first([configMantaNormal.tbiSomaticSV, configMantaTumor.tbiSomaticSV])
    File outputAlignmentStatsSummary = select_first([configMantaNormal.alignmentStatsSummary, configMantaTumor.alignmentStatsSummary])
    File outputSvCandidateGenerationStatsTSV = select_first([configMantaNormal.svCandidateGenerationStatsTSV, configMantaTumor.svCandidateGenerationStatsTSV])
    File outputSvCandidateGenerationStatsXML = select_first([configMantaNormal.svCandidateGenerationStatsXML, configMantaTumor.svCandidateGenerationStatsXML])
    File outputSvLocusGraphStats = select_first([configMantaNormal.svLocusGraphStats, configMantaTumor.svLocusGraphStats])
  }
}

task configMantaNormal {
  input {
    Array[File]? normalBam
    String bam
    Array[File]? normalBai
    File? tumorBam
    File? tumorBai
    File? callRegionsFile
    String referenceModule
    String referenceFasta
    String normalBamCommand
    String tumorBamCommand
    String exomeCommand
    String rnaCommand
    String unstrandedRNACommand
    String callRegionsCommand
    Int threads = 6
    Int jobMemory = 16
    Int timeout = 6  
    String modules = "illumina-manta/1.6.0 ~{referenceModule} python/2.7"
  } 
  parameter_meta {
    normalBam: "Reference BAM file"
    tumorBam: "Tumor BAM file"
    referenceFasta: "HG19 or HG38 fasta file"
    modules: "Module needed to run manta"
    jobMemory: "Memory (GB) allocated for this job"
    threads: "Requested CPU threads"
    timeout: "Number of hours before task timeout"
  }
  command <<<
    configManta.py --bam ~{sep=" --bam " normalBam} ~{tumorBamCommand} ~{exomeCommand} ~{rnaCommand} ~{unstrandedRNACommand} --referenceFasta "~{referenceFasta}" --runDir . ~{callRegionsCommand};
    python2.7 runWorkflow.py;
    mv results/variants/*.vcf.gz .;
    mv results/variants/*.gz.tbi .
    fi 
    if [ "~{bam}" == "false" ]; then
      configManta.py ~{tumorBamCommand} ~{exomeCommand} ~{rnaCommand} ~{unstrandedRNACommand} --referenceFasta "~{referenceFasta}" --runDir . ~{callRegionsCommand};
      python2.7 runWorkflow.py;
      mv results/variants/*.vcf.gz .;
      mv results/variants/*.gz.tbi .
    fi
    
  >>>
  runtime {
    modules: "~{modules}"
    memory:  "~{jobMemory} GB"
    cpu:     "~{threads}"
    timeout: "~{timeout}"
  }
  output {
    File? vcfCandidateSV = "candidateSV.vcf.gz"
    File? tbiCandidateSV = "candidateSV.vcf.gz.tbi"
    File? vcfCandidateSmallIndels = "candidateSmallIndels.vcf.gz"
    File? tbiCandidateSmallIndels = "candidateSmallIndels.vcf.gz.tbi"
    File? vcfTumorSV = "tumorSV.vcf.gz"
    File? tbiTumorSV = "tumorSV.vcf.gz.tbi"   
    File? vcfDiploidSV = "diploidSV.vcf.gz"
    File? tbiDiploidSV = "diploidSV.vcf.gz.tbi"   
    File? vcfSomaticSV = "somaticSV.vcf.gz"
    File? tbiSomaticSV = "somaticSV.vcf.gz.tbi"    
    File alignmentStatsSummary = "./results/stats/alignmentStatsSummary.txt"
    File svCandidateGenerationStatsTSV = "./results/stats/svCandidateGenerationStats.tsv"
    File svCandidateGenerationStatsXML = "./results/stats/svCandidateGenerationStats.xml"
    File svLocusGraphStats = "./results/stats/svLocusGraphStats.tsv"
  }
  meta {
    output_meta: {
      vcfFiles: "All VCF files",
      tbiFiles: "All TBI Files",
      alignmentStatsSummary: "Summary of alignment stats",
      svCandidateGenerationStatsTSV: "TSV stats",
      svCandidateGenerationStatsXML: "XML stats",
      svLocusGraphStats: "Locus graph for structural variants" 
    }
  }
}

task configMantaTumor {
  input {
    Array[File]? normalBam
    String bam
    Array[File]? normalBai
    File? tumorBam
    File? tumorBai
    File? callRegionsFile
    String referenceModule
    String referenceFasta
    String normalBamCommand
    String tumorBamCommand
    String exomeCommand
    String rnaCommand
    String unstrandedRNACommand
    String callRegionsCommand
    Int threads = 6
    Int jobMemory = 16
    Int timeout = 6  
    String modules = "illumina-manta/1.6.0 ~{referenceModule} python/2.7"
  } 
  parameter_meta {
    normalBam: "Reference BAM file"
    tumorBam: "Tumor BAM file"
    referenceFasta: "HG19 or HG38 fasta file"
    modules: "Module needed to run manta"
    jobMemory: "Memory (GB) allocated for this job"
    threads: "Requested CPU threads"
    timeout: "Number of hours before task timeout"
  }
  command <<<
    configManta.py ~{tumorBamCommand} ~{exomeCommand} ~{rnaCommand} ~{unstrandedRNACommand} --referenceFasta "~{referenceFasta}" --runDir . ~{callRegionsCommand};
    python2.7 runWorkflow.py;
    mv results/variants/*.vcf.gz .;
    mv results/variants/*.gz.tbi .
    
  >>>
  runtime {
    modules: "~{modules}"
    memory:  "~{jobMemory} GB"
    cpu:     "~{threads}"
    timeout: "~{timeout}"
  }
  output {
    File? vcfCandidateSV = "candidateSV.vcf.gz"
    File? tbiCandidateSV = "candidateSV.vcf.gz.tbi"
    File? vcfCandidateSmallIndels = "candidateSmallIndels.vcf.gz"
    File? tbiCandidateSmallIndels = "candidateSmallIndels.vcf.gz.tbi"
    File? vcfTumorSV = "tumorSV.vcf.gz"
    File? tbiTumorSV = "tumorSV.vcf.gz.tbi"   
    File? vcfDiploidSV = "diploidSV.vcf.gz"
    File? tbiDiploidSV = "diploidSV.vcf.gz.tbi"   
    File? vcfSomaticSV = "somaticSV.vcf.gz"
    File? tbiSomaticSV = "somaticSV.vcf.gz.tbi"    
    File alignmentStatsSummary = "./results/stats/alignmentStatsSummary.txt"
    File svCandidateGenerationStatsTSV = "./results/stats/svCandidateGenerationStats.tsv"
    File svCandidateGenerationStatsXML = "./results/stats/svCandidateGenerationStats.xml"
    File svLocusGraphStats = "./results/stats/svLocusGraphStats.tsv"
  }
  meta {
    output_meta: {
      vcfFiles: "All VCF files",
      tbiFiles: "All TBI Files",
      alignmentStatsSummary: "Summary of alignment stats",
      svCandidateGenerationStatsTSV: "TSV stats",
      svCandidateGenerationStatsXML: "XML stats",
      svLocusGraphStats: "Locus graph for structural variants" 
    }
  }
}
