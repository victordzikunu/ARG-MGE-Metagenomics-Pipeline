rule megahit:
    input:
        r1="results/trimmed/{sample}_R1.fastq.gz",
        r2="results/trimmed/{sample}_R2.fastq.gz",
    output:
        contigs="results/assembly/{sample}/final.contigs.fa",
    log:
        "logs/megahit/{sample}.log",
    conda:
        "../envs/megahit.yml"
    threads: config["threads"]["megahit"]
    params:
        mem=config["megahit"]["memory"],
    shell:
        """
        START=$(date +%s)

        echo "[INFO] =======================================" | tee {log}
        echo "[INFO] Rule: megahit" | tee -a {log}
        echo "[INFO] Sample: {wildcards.sample}" | tee -a {log}
        echo "[INFO] Started: $(date)" | tee -a {log}
        echo "[INFO] =======================================" | tee -a {log}

        trap '
            STATUS=$?
            END=$(date +%s)

            echo "[ERROR] =======================================" | tee -a {log}
            echo "[ERROR] MEGAHIT failed" | tee -a {log}
            echo "[ERROR] Sample: {wildcards.sample}" | tee -a {log}
            echo "[ERROR] Exit Code: ${{STATUS}}" | tee -a {log}
            echo "[ERROR] Failed: $(date)" | tee -a {log}
            echo "[ERROR] Runtime: $((END-START)) seconds" | tee -a {log}
            echo "[ERROR] =======================================" | tee -a {log}

            exit ${{STATUS}}
        ' ERR

        echo "[INFO] Running MEGAHIT..." | tee -a {log}

        megahit \
            -1 {input.r1} \
            -2 {input.r2} \
            --kmin-1pass \
            -t {threads} \
            -m {params.mem} \
            -o results/assembly/{wildcards.sample} \
            >>{log} 2>&1

        # Output validation
        if [ ! -s {output.contigs} ]; then
            echo "[ERROR] final.contigs.fa was not generated." | tee -a {log}
            exit 1
        fi

        END=$(date +%s)

        echo "[INFO] MEGAHIT completed successfully." | tee -a {log}
        echo "[INFO] Completed: $(date)" | tee -a {log}
        echo "[INFO] Runtime: $((END - START)) seconds" | tee -a {log}
        echo "[INFO] =======================================" | tee -a {log}
        """
