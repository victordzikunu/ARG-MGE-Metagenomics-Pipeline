# FastQC on Raw Reads


rule fastqc_raw:
    input:
        "data/raw/{sample}_{read}.fastq.gz",
    output:
        html="results/fastqc/raw/{sample}_{read}_fastqc.html",
        zip="results/fastqc/raw/{sample}_{read}_fastqc.zip",
    log:
        "logs/fastqc/raw_{sample}_{read}.log",
    conda:
        "../envs/fastqc.yml"
    shell:
        """
        START=$(date +%s)

        echo "[INFO] =======================================" | tee {log}
        echo "[INFO] Rule: fastqc_raw" | tee -a {log}
        echo "[INFO] Sample: {wildcards.sample}" | tee -a {log}
        echo "[INFO] Read: {wildcards.read}" | tee -a {log}
        echo "[INFO] Started: $(date)" | tee -a {log}
        echo "[INFO] =======================================" | tee -a {log}

        trap '
            STATUS=$?
            END=$(date +%s)

            echo "[ERROR] =======================================" | tee -a {log}
            echo "[ERROR] FastQC Raw Failed" | tee -a {log}
            echo "[ERROR] Sample: {wildcards.sample}" | tee -a {log}
            echo "[ERROR] Read: {wildcards.read}" | tee -a {log}
            echo "[ERROR] Exit Code: ${{STATUS}}" | tee -a {log}
            echo "[ERROR] Runtime: $((END-START)) seconds" | tee -a {log}
            echo "[ERROR] =======================================" | tee -a {log}

            exit ${{STATUS}}
        ' ERR

        echo "[INFO] Running FastQC Raw..." | tee -a {log}

        fastqc \
            {input} \
            -o results/fastqc/raw \
            >>{log} 2>&1

        if [ ! -s {output.html} ]; then
            echo "[ERROR] FastQC HTML report missing." | tee -a {log}
            exit 1
        fi

        if [ ! -s {output.zip} ]; then
            echo "[ERROR] FastQC ZIP report missing." | tee -a {log}
            exit 1
        fi

        END=$(date +%s)

        echo "[INFO] FastQC raw completed successfully." | tee -a {log}
        echo "[INFO] Completed: $(date)" | tee -a {log}
        echo "[INFO] Runtime: $((END - START)) seconds" | tee -a {log}
        echo "[INFO] =======================================" | tee -a {log}
        """


# FastQC on Trimmed Reads


rule fastqc_trimmed:
    input:
        "results/trimmed/{sample}_{read}.fastq.gz",
    output:
        html="results/fastqc/trimmed/{sample}_{read}_fastqc.html",
        zip="results/fastqc/trimmed/{sample}_{read}_fastqc.zip",
    log:
        "logs/fastqc/trimmed_{sample}_{read}.log",
    conda:
        "../envs/fastqc.yml"
    shell:
        """
        START=$(date +%s)

        echo "[INFO] =======================================" | tee {log}
        echo "[INFO] Rule: fastqc_trimmed" | tee -a {log}
        echo "[INFO] Sample: {wildcards.sample}" | tee -a {log}
        echo "[INFO] Read: {wildcards.read}" | tee -a {log}
        echo "[INFO] Started: $(date)" | tee -a {log}
        echo "[INFO] =======================================" | tee -a {log}

        trap '
            STATUS=$?
            END=$(date +%s)

            echo "[ERROR] =======================================" | tee -a {log}
            echo "[ERROR] FastQC Trimmed Failed" | tee -a {log}
            echo "[ERROR] Sample: {wildcards.sample}" | tee -a {log}
            echo "[ERROR] Read: {wildcards.read}" | tee -a {log}
            echo "[ERROR] Exit Code: ${{STATUS}}" | tee -a {log}
            echo "[ERROR] Runtime: $((END-START)) seconds" | tee -a {log}
            echo "[ERROR] =======================================" | tee -a {log}

            exit ${{STATUS}}
        ' ERR

        echo "[INFO] Running FastQC Trimmed..." | tee -a {log}

        fastqc \
            {input} \
            -o results/fastqc/trimmed \
            >>{log} 2>&1

        if [ ! -s {output.html} ]; then
            echo "[ERROR] FastQC HTML report missing." | tee -a {log}
            exit 1
        fi

        if [ ! -s {output.zip} ]; then
            echo "[ERROR] FastQC ZIP report missing." | tee -a {log}
            exit 1
        fi

        END=$(date +%s)

        echo "[INFO] FastQC trimmed completed successfully." | tee -a {log}
        echo "[INFO] Completed: $(date)" | tee -a {log}
        echo "[INFO] Runtime: $((END - START)) seconds" | tee -a {log}
        echo "[INFO] =======================================" | tee -a {log}
        """
