rule rgi:
    input:
        "results/assembly/{sample}/final.contigs.fa",
    output:
        "results/rgi/{sample}_rgi.txt",
    log:
        "logs/rgi/{sample}.log",
    conda:
        "../envs/rgi.yml"
    threads: config["threads"]["rgi"]
    shell:
        """
        START=$(date +%s)

        echo "[INFO] =======================================" | tee {log}
        echo "[INFO] Rule: rgi" | tee -a {log}
        echo "[INFO] Sample: {wildcards.sample}" | tee -a {log}
        echo "[INFO] Started: $(date)" | tee -a {log}
        echo "[INFO] =======================================" | tee -a {log}

        trap '
            STATUS=$?
            END=$(date +%s)

            echo "[ERROR] RGI failed" | tee -a {log}
            echo "[ERROR] Sample: {wildcards.sample}" | tee -a {log}
            echo "[ERROR] Exit Code: ${{STATUS}}" | tee -a {log}
            echo "[ERROR] Runtime: $((END-START)) seconds" | tee -a {log}

            exit ${{STATUS}}
        ' ERR

        echo "[INFO] Running RGI main..." | tee -a {log}

        rgi main \
            --input_sequence {input} \
            --input_type contig \
            --alignment_tool BLAST \
            --num_threads {threads} \
            --output_file results/rgi/{wildcards.sample} \
            >>{log} 2>&1

        # Output validation
        if [ ! -s {output} ]; then
            echo "[ERROR] RGI output missing" | tee -a {log}
            exit 1
        fi

        # Number of ARG Hits
        ARG_COUNT=$(tail -n +2 {output} | wc -l)

        echo "[INFO] ARG Hits: ${{ARG_COUNT}}" | tee -a {log}

        END=$(date +%s)

        echo "[INFO] Completed: $(date)" | tee -a {log}
        echo "[INFO] Runtime: $((END - START)) seconds" | tee -a {log}
        echo "[INFO] =======================================" | tee -a {log}
        """


# Convert RGI output into a BED file
rule rgi_to_bed:
    input:
        "results/rgi/{sample}_rgi.txt",
    output:
        "results/rgi/{sample}.bed",
    log:
        "logs/rgi/{sample}_bed.log",
    shell:
        r"""
        START=$(date +%s)

        echo "[INFO] =======================================" | tee {log}
        echo "[INFO] Rule: rgi_to_bed" | tee -a {log}
        echo "[INFO] Sample: {wildcards.sample}" | tee -a {log}
        echo "[INFO] Started: $(date)" | tee -a {log}
        echo "[INFO] =======================================" | tee -a {log}

        trap '
            STATUS=$?
            END=$(date +%s)

            echo "[ERROR] =======================================" | tee -a {log}
            echo "[ERROR] BED file conversion failed" | tee -a {log}
            echo "[ERROR] Runtime: $((END-START)) seconds" | tee -a {log}
            echo "[ERROR] =======================================" | tee -a {log}

            exit ${{STATUS}}
        ' ERR

        echo "[INFO] Converting RGI output to BED file..." | tee -a {log}

        awk -F'\t' 'BEGIN {{OFS="\t"}}
        NR>1 {{
            start=$3-1
            end=$4

            if (start >= 0 && end > start)
                print $2, start, end, $9
        }}' {input} >{output}

        END=$(date +%s)

        echo "[INFO] Conversion completed successfully." | tee -a {log}
        echo "[INFO] Completed: $(date)" | tee -a {log}
        echo "[INFO] Runtime: $((END - START)) seconds" | tee -a {log}
        echo "[INFO] =======================================" | tee -a {log}
        """


# Extract Unique ARG Contig IDs
rule rgi_contig_list:
    input:
        "results/rgi/{sample}.bed",
    output:
        "results/rgi/{sample}_contigs.txt",
    log:
        "logs/rgi/{sample}_contigs.log",
    shell:
        """
        START=$(date +%s)

        echo "[INFO] =======================================" | tee {log}
        echo "[INFO] Rule: rgi_contig_list" | tee -a {log}
        echo "[INFO] Sample: {wildcards.sample}" | tee -a {log}
        echo "[INFO] Started: $(date)" | tee -a {log}
        echo "[INFO] =======================================" | tee -a {log}

        trap '
            STATUS=$?
            END=$(date +%s)

            echo "[ERROR] =======================================" | tee -a {log}
            echo "[ERROR] Contig extraction failed" | tee -a {log}
            echo "[ERROR] Sample: {wildcards.sample}" | tee -a {log}
            echo "[ERROR] Exit Code: ${{STATUS}}" | tee -a {log}
            echo "[ERROR] Runtime: $((END-START)) seconds" | tee -a {log}
            echo "[ERROR] =======================================" | tee -a {log}

            exit ${{STATUS}}
        ' ERR

        echo "[INFO] Running Contig extraction..." | tee -a {log}

        cut -f1 {input} | sort -u >{output}

        # Statistics
        if [ ! -s {output} ]; then
            echo "[WARNING] No ARG-containing contigs detected." | tee -a {log}
        fi

        CONTIGS=$(wc -l <{output} || echo 0)

        echo "[INFO] Unique ARG contigs: ${{CONTIGS}}" | tee -a {log}

        END=$(date +%s)

        echo "[INFO] Contig extraction completed successfully." | tee -a {log}
        echo "[INFO] Completed: $(date)" | tee -a {log}
        echo "[INFO] Runtime: $((END - START)) seconds" | tee -a {log}
        echo "[INFO] =======================================" | tee -a {log}
        """
