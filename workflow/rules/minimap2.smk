rule minimap2:
    input:
        contigs="results/assembly/{sample}/final.contigs.fa",
        r1="results/trimmed/{sample}_R1.fastq.gz",
        r2="results/trimmed/{sample}_R2.fastq.gz",
    output:
        bam="results/mapping/{sample}.bam",
        bai="results/mapping/{sample}.bam.bai",
    log:
        "logs/mapping/{sample}.log",
    conda:
        "../envs/mapping.yml"
    threads: config["threads"]["minimap2"] + config["threads"]["samtools"]
    params:
        minimap2_threads=config["threads"]["minimap2"],
        samtools_threads=config["threads"]["samtools"],
    shell:
        """
        START=$(date +%s)

        echo "[INFO] =======================================" | tee {log}
        echo "[INFO] Rule: minimap2" | tee -a {log}
        echo "[INFO] Sample: {wildcards.sample}" | tee -a {log}
        echo "[INFO] Started: $(date)" | tee -a {log}
        echo "[INFO] =======================================" | tee -a {log}

        trap '
            STATUS=$?
            END=$(date +%s)

            echo "[ERROR] =======================================" | tee -a {log}
            echo "[ERROR] Mapping failed" | tee -a {log}
            echo "[ERROR] Sample: {wildcards.sample}" | tee -a {log}
            echo "[ERROR] Exit Code: ${{STATUS}}" | tee -a {log}
            echo "[ERROR] Runtime: $((END-START)) seconds" | tee -a {log}
            echo "[ERROR] =======================================" | tee -a {log}

            exit ${{STATUS}}
        ' ERR

        echo "[INFO] Running mapping and sorting..." | tee -a {log}

        # Map Reads and Sort BAM

        minimap2 \
            -ax sr \
            -t {params.minimap2_threads} \
            {input.contigs} \
            {input.r1} \
            {input.r2} \
            | samtools sort \
                -@ {params.samtools_threads} \
                -o {output.bam}

        # Index BAM

        echo "[INFO] Running Indexing BAM..." | tee -a {log}

        samtools index {output.bam}

        # Validate Outputs

        if [ ! -s {output.bam} ]; then
            echo "[ERROR] BAM file not generated." | tee -a {log}
            exit 1
        fi

        if [ ! -s {output.bai} ]; then
            echo "[ERROR] BAM index not generated." | tee -a {log}
            exit 1
        fi

        END=$(date +%s)

        echo "[INFO] Mapping and Indexing completed successfully." | tee -a {log}
        echo "[INFO] Completed: $(date)" | tee -a {log}
        echo "[INFO] Runtime: $((END - START)) seconds" | tee -a {log}
        echo "[INFO] =======================================" | tee -a {log}
        """
