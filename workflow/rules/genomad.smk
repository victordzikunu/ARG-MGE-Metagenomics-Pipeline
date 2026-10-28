rule genomad:
    input:
        fasta="results/rgi/{sample}_ARG_contigs.fa",
    output:
        directory("results/genomad/{sample}"),
    log:
        "logs/genomad/{sample}.log",
    conda:
        "../envs/genomad.yml"
    threads: config["threads"]["genomad"]
    params:
        db=config["databases"]["genomad"],
    shell:
        """
        START=$(date +%s)

        echo "[INFO] =======================================" | tee {log}
        echo "[INFO] Rule: genomad" | tee -a {log}
        echo "[INFO] Sample: {wildcards.sample}" | tee -a {log}
        echo "[INFO] Started: $(date)" | tee -a {log}
        echo "[INFO] =======================================" | tee -a {log}

        trap '
            STATUS=$?
            END=$(date +%s)

            echo "[ERROR] =======================================" | tee -a {log}
            echo "[ERROR] geNomad failed" | tee -a {log}
            echo "[ERROR] Sample: {wildcards.sample}" | tee -a {log}
            echo "[ERROR] Exit Code: ${{STATUS}}" | tee -a {log}
            echo "[ERROR] Failed: $(date)" | tee -a {log}
            echo "[ERROR] Runtime: $((END-START)) seconds" | tee -a {log}
            echo "[ERROR] =======================================" | tee -a {log}

            exit ${{STATUS}}
        ' ERR

        # Handle Samples with No ARG Contigs

        if [ ! -s {input.fasta} ]; then

            echo "[WARNING] No ARG-containing contigs found." \
                | tee -a {log}

            mkdir -p {output}

            touch {output}/SKIPPED_NO_ARG_CONTIGS.txt

            END=$(date +%s)

            echo "[INFO] Skipping geNomad." | tee -a {log}
            echo "[INFO] Runtime: $((END - START)) seconds" | tee -a {log}

            exit 0
        fi

        echo "[INFO] Running geNomad..." | tee -a {log}

        genomad end-to-end \
            --threads {threads} \
            --cleanup \
            --splits 8 \
            {input.fasta} \
            {output} \
            {params.db} \
            >>{log} 2>&1

        # Validate output
        if [ ! -d {output} ]; then
            echo "[ERROR] geNomad output directory missing." \
                | tee -a {log}
            exit 1
        fi

        END=$(date +%s)

        echo "[INFO] Seqtk contig extraction completed successfully." | tee -a {log}
        echo "[INFO] Completed: $(date)" | tee -a {log}
        echo "[INFO] Runtime: $((END - START)) seconds" | tee -a {log}
        echo "[INFO] =======================================" | tee -a {log}
        """
