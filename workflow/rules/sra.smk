rule download_sra:
    output:
        r1="data/raw/{sample}_R1.fastq.gz",
        r2="data/raw/{sample}_R2.fastq.gz",
    log:
        "logs/sra/{sample}.log",
    conda:
        "../envs/sra.yml"
    shell:
        """
        START=$(date +%s)

        echo "[INFO] =======================================" | tee {log}
        echo "[INFO] Rule: download_sra" | tee {log}
        echo "[INFO] Sample: {wildcards.sample}" | tee -a {log}
        echo "[INFO] Started: $(date)" | tee -a {log}
        echo "[INFO] =======================================" | tee {log}

        trap '
            STATUS=$?
            END=$(date +%s)

            echo "[ERROR] =======================================" | tee -a {log}
            echo "[ERROR] SRA download failed" | tee -a {log}
            echo "[ERROR] Sample: {wildcards.sample}" | tee -a {log}
            echo "[ERROR] Exit Code: ${{STATUS}}" | tee -a {log}
            echo "[ERROR] Failed: $(date)" | tee -a {log}
            echo "[ERROR] Runtime: $((END-START)) seconds" | tee -a {log}
            echo "[ERROR] =======================================" | tee -a {log}

            exit ${{STATUS}}
        ' ERR

        mkdir -p tmp/{wildcards.sample}

        echo "[INFO] Running prefetch..." | tee -a {log}

        prefetch {wildcards.sample} >>{log} 2>&1

        echo "[INFO] Running fasterq-dump..." | tee -a {log}

        fasterq-dump \
            {wildcards.sample} \
            --split-files \
            --outdir tmp/{wildcards.sample} \
            >>{log} 2>&1

        echo "[INFO] Compressing FASTQ files..." | tee -a {log}

        gzip tmp/{wildcards.sample}/{wildcards.sample}_1.fastq
        gzip tmp/{wildcards.sample}/{wildcards.sample}_2.fastq

        mv tmp/{wildcards.sample}/{wildcards.sample}_1.fastq.gz {output.r1}
        mv tmp/{wildcards.sample}/{wildcards.sample}_2.fastq.gz {output.r2}

        if [ ! -s {output.r1} ]; then
            echo "[ERROR] R1 FASTQ missing or empty." | tee -a {log}
            exit 1
        fi

        if [ ! -s {output.r2} ]; then
            echo "[ERROR] R2 FASTQ missing or empty." | tee -a {log}
            exit 1
        fi

        rm -rf tmp/{wildcards.sample}

        END=$(date +%s)

        echo "[INFO] Completed: $(date)" | tee -a {log}
        echo "[INFO] Runtime: $((END - START)) seconds" | tee -a {log}
        echo "[INFO] =======================================" | tee -a {log}
        """
