version 1.0 
workflow manta {
  input {
      Array[String]? normalBam
      Array[File]? normalBai
      File? tumorBam
      File? tumorBai
      Boolean? exome
      Boolean? rna
      Boolean? unstrandedRNA
      File? callRegionsFile
  }
   String normalBamCommand = if defined(normalBam) == true then "--bam" else ""
   String bam = if defined(normalBam) == true then "true" else "false"
   String tumorBamCommand = if defined(tumorBam) == true then "--tumorBam ~{tumorBam}" else ""
   String exomeCommand = if defined(exome) == true then "--exome" else ""
   String rnaCommand = if defined(rna) == true then "--rna" else ""
   String unstrandedRNACommand = if defined(unstrandedRNA) == true then "--unstrandedRNA" else ""
   String callRegionsCommand = if defined(callRegionsFile) == true then "--callregions ~{callRegionsFile}" else ""



  call configManta {
    input: normalBam = normalBam,
           bam = bam,
           normalBai = normalBai,
           tumorBam = tumorBam,
           tumorBai = tumorBai,
           callRegionsFile = callRegionsFile,
           normalBamCommand = normalBamCommand,
           tumorBamCommand = tumorBamCommand,
           exomeCommand = exomeCommand,
           rnaCommand = rnaCommand,
           unstrandedRNACommand = unstrandedRNACommand,
           callRegionsCommand = callRegionsCommand
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
    Array[File] outputVcfFiles = configManta.vcfFiles
    Array[File] outputTbiFiles = configManta.tbiFiles
    File outputAlignmentStatsSummary = configManta.alignmentStatsSummary
    File outputSvCandidateGenerationStatsTSV = configManta.svCandidateGenerationStatsTSV
    File outputSvCandidateGenerationStatsXML = configManta.svCandidateGenerationStatsXML
    File outputSvLocusGraphStats = configManta.svLocusGraphStats   
  }
}

task configManta {
  input {
    Array[String]? normalBam
    String bam
    Array[File]? normalBai
    File? tumorBam
    File? tumorBai
    File? callRegionsFile
    String referenceFasta = "$HG19_ROOT/hg19_random.fa"
    String normalBamCommand
    String tumorBamCommand
    String exomeCommand
    String rnaCommand
    String unstrandedRNACommand
    String callRegionsCommand
    Int threads = 6
    Int jobMemory = 16
    Int timeout = 6  
    String modules = "illumina-manta/1.6.0 hg19/p13 python/2.7"
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
    if [ "~{bam}" == "true" ]; then
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
    Array[File] vcfFiles = glob("*.vcf.gz")
    Array[File] tbiFiles = glob("*.gz.tbi")
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
