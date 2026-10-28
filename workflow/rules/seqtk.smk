rule extract_arg_contigs:
    input:
        assembly="results/assembly/{sample}/final.contigs.fa",
        contigs="results/rgi/{sample}_contigs.txt",
    output:
        "results/rgi/{sample}_ARG_contigs.fa",
    log:
        "logs/seqtk/{sample}.log",
    conda:
        "../envs/seqtk.yml"
    shell:
        """
        START=$(date +%s)

        echo "[INFO] =======================================" | tee {log}
        echo "[INFO] Rule: extract_arg_contig" | tee -a {log}
        echo "[INFO] Sample: {wildcards.sample}" | tee -a {log}
        echo "[INFO] Started: $(date)" | tee -a {log}
        echo "[INFO] =======================================" | tee -a {log}

        trap '
            STATUS=$?
            END=$(date +%s)

            echo "[ERROR] =======================================" | tee -a {log}
            echo "[ERROR] Seqtk extraction failed" | tee -a {log}
            echo "[ERROR] Sample: {wildcards.sample}" | tee -a {log}
            echo "[ERROR] Exit Code: ${{STATUS}}" | tee -a {log}
            echo "[ERROR] Runtime: $((END-START)) seconds" | tee -a {log}
            echo "[ERROR] =======================================" | tee -a {log}

            exit ${{STATUS}}
        ' ERR

        # Handling if there is no ARG contigs
        if [ ! -s {input.contigs} ]; then

            echo "[WARNING] No ARG-containing contigs detected." | tee -a {log}

            touch {output}

            END=$(date +%s)

            echo "[INFO] Skipping Seqtk extraction." | tee -a {log}
            echo "[INFO] Runtime: $((END - START)) seconds" | tee -a {log}

            exit 0
        fi

        echo "[INFO] Running Seqtk contig extraction..." | tee -a {log}

        seqtk subseq \
            {input.assembly} \
            {input.contigs} \
            >{output} \
            2>>{log}

        END=$(date +%s)

        echo "[INFO] Seqtk contig extraction completed successfully." | tee -a {log}
        echo "[INFO] Completed: $(date)" | tee -a {log}
        echo "[INFO] Runtime: $((END - START)) seconds" | tee -a {log}
        echo "[INFO] =======================================" | tee -a {log}
        """
