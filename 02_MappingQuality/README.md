**02_1_MappingQuality.sh**

We used vg stats to obtain the number of nodes and edges, biologically plausible paths and length for each variation-aware reference graph. To assess the accuracy of graph-based alignment, we converted the Graph Alignment Map (GAM)-files to JavaScript Object Notation (JSON)-files using vg view. Subsequently, we applied the command-line JSON processor jq (https://stedolan.github.io/jq/) to extract mapping information for each read. Mapping information from linear alignments were extracted using samtools (v1.17). To assess the read mapping accuracy from the sequencing data, we calculated the proportion of reads aligned perfectly. A read was considered to map perfectly if the edit distance was zero along the entire read (NM:0 tag in BWA mem-aligned BAM files; identity 1 in vg map-aligned GAM-files), and without hard clippings (H tag) or soft clipping (S tag) in CIGAR string. 

**02_2_MappingQuality_R_ANalysis.sh**
Analysis in R
