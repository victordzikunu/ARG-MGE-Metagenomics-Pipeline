rule quast:
    input:
        assembly="results/assembly/{sample}/final.contigs.fa",
    output:
        report="results/quast/{sample}/report.tsv",
    log:
        "logs/quast/{sample}.log",
    conda:
        "../envs/quast.yml"
    threads: config["threads"]["quast"]
    shell:
        """
        START=$(date +%s)

        echo "[INFO] =======================================" | tee {log}
        echo "[INFO] Rule: quast" | tee -a {log}
        echo "[INFO] Sample: {wildcards.sample}" | tee -a {log}
        echo "[INFO] Started: $(date)" | tee -a {log}
        echo "[INFO] =======================================" | tee -a {log}

        trap '
            STATUS=$?
            END=$(date +%s)

            echo "[ERROR] =======================================" | tee -a {log}
            echo "[ERROR] Quast failed" | tee -a {log}
            echo "[ERROR] Sample: {wildcards.sample}" | tee -a {log}
            echo "[ERROR] Exit Code: ${{STATUS}}" | tee -a {log}
            echo "[ERROR] Failed: $(date)" | tee -a {log}
            echo "[ERROR] Runtime: $((END-START)) seconds" | tee -a {log}
            echo "[ERROR] =======================================" | tee -a {log}

            exit ${{STATUS}}
        ' ERR

        echo "[INFO] Running Quast..." | tee -a {log}

        quast.py \
            --threads {threads} \
            {input.assembly} \
            -o results/quast/{wildcards.sample} \
            >>{log} 2>&1

        END=$(date +%s)

        echo "[INFO] Quast completed successfully." | tee -a {log}
        echo "[INFO] Completed: $(date)" | tee -a {log}
        echo "[INFO] Runtime: $((END - START)) seconds" | tee -a {log}
        echo "[INFO] =======================================" | tee -a {log}
        """
