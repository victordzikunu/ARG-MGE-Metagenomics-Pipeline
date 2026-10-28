rule mobileelementfinder:
    input:
        fasta="results/rgi/{sample}_ARG_contigs.fa",
    output:
        report="results/mobileelementfinder/{sample}/report.tsv",
    log:
        "logs/mobileelementfinder/{sample}.txt",
    conda:
        "/envs/mobileelementfinder.yml"
    threads: config["threads"]["mobileelementfinder"]
    params:
        db=config["databases"]["mobileelementfinder"],
    shell:
        """
        START=$(date +%s)

        echo "[INFO] =======================================" | tee {log}
        echo "[INFO] Rule: mobileelementfinder" | tee -a {log}
        echo "[INFO] Sample: {wildcards.sample}" | tee -a {log}
        echo "[INFO] Started: $(date)" | tee -a {log}
        echo "[INFO] =======================================" | tee -a {log}

        trap '
            STATUS=$?
            END=$(date +%s)

            echo "[ERROR] =======================================" | tee -a {log}
            echo "[ERROR] MobileElementFinder failed" | tee -a {log}
            echo "[ERROR] Sample: {wildcards.sample}" | tee -a {log}
            echo "[ERROR] Exit Code: ${{STATUS}}" | tee -a {log}
            echo "[ERROR] Runtime: $((END-START)) seconds" | tee -a {log}
            echo "[ERROR] =======================================" | tee -a {log}

            exit ${{STATUS}}
        ' ERR

        # No ARG Contigs Found
        if [ ! -s {input.fasta} ]; then

            echo "[WARNING] No ARG contigs available." | tee -a {log}

            mkdir -p results/mobileelementfinder/{wildcards.sample}

            touch {output.report}

            END=$(date +%s)

            echo "[INFO] Skipping MobileElementFinder." | tee -a {log}
            echo "[INFO] Runtime: $((END - START)) seconds" | tee -a {log}

            exit 0
        fi

        echo "[INFO] Running Mobile Element Finder..." | tee -a {log}

        # Run MobileElementFinder
        mefinder find \
            --contig {input.fasta} \
            --gff
        --json
        --threads {threads}
        --db-path {params.db} \
            results/mobileelementfinder/{wildcards.sample}/{wildcards.sample} \
            >>{log} 2>&1

        #Validate output
        if [ ! -f {output.report} ]; then
            echo "[ERROR] MobileElementFinder report not produced." \
                | tee -a {log}
            exit 1
        fi

        END=$(date +%s)

        echo "[INFO] Seqtk contig extraction completed successfully." | tee -a {log}
        echo "[INFO] Completed: $(date)" | tee -a {log}
        echo "[INFO] Runtime: $((END - START)) seconds" | tee -a {log}
        echo "[INFO] =======================================" | tee -a {log}
        """
