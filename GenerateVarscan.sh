#!bin/bash

perl /gcc/groups/oncogenetics/prm02/data/mytools/molgenis-compute-core-1.0.0-SNAPSHOT/workflows/Varscan2/convertParametersGitToMolgenis.pl parameters.csv > parameters.molgenis.csv

module load jdk/1.7.0_51

bash /gcc/groups/oncogenetics/prm02/data/mytools/molgenis-compute-core-1.0.0-SNAPSHOT/molgenis_compute.sh \
 --generate \
 -p /gcc/groups/oncogenetics/prm02/data/mytools/molgenis-compute-core-1.0.0-SNAPSHOT/workflows/Varscan2/parameters.molgenis.csv \
 -p /gcc/groups/oncogenetics/prm02/data/mytools/molgenis-compute-core-1.0.0-SNAPSHOT/workflows/Varscan2/parametersVars.csv \
 -w /gcc/groups/oncogenetics/prm02/data/mytools/molgenis-compute-core-1.0.0-SNAPSHOT/workflows/Varscan2/workflow.csv \
 --backend pbs \
 --weave \
 -rundir /gcc/groups/oncogenetics/tmp02/projects/Varscan2Workflow/runs \
 -runid run01 \
 -header /gcc/groups/oncogenetics/prm02/data/mytools/molgenis-compute-core-1.0.0-SNAPSHOT/templates/pbs/header.ftl \
 -submit /gcc/groups/oncogenetics/prm02/data/mytools/molgenis-compute-core-1.0.0-SNAPSHOT/templates/pbs/submit.ftl
# -header ../../templates/pbs/header.ftl \
# -footer ../../templates/pbs/footer.ftl \
# -submit ../../templates/pbs/submit.ftl

