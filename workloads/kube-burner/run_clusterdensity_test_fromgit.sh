#!/usr/bin/bash -e

set -e

WORKLOAD_TEMPLATE=workloads/cluster-density/cluster-density.yml
METRICS_PROFILE=${METRICS_PROFILE:-metrics-profiles/metrics-aggregated.yaml}
export TEST_JOB_ITERATIONS=${JOB_ITERATIONS:-1}
export WORKLOAD=cluster-density

. common.sh

deploy_operator
check_running_benchmarks
if [[ ${PPROF_COLLECTION} == "true" ]] ; then
  delete_pprof_secrets
  delete_oldpprof_folder
  get_pprof_secrets
fi
deploy_workload
wait_for_benchmark ${WORKLOAD}
rm -rf benchmark-operator
if [[ ${CLEANUP_WHEN_FINISH} == "true" ]]; then
  cleanup
fi
delete_pprof_secrets

ls

if [[ ${ENABLE_SNAPPY_BACKUP} == "true" ]] ; then
  snappy_backup kube-burner-clusterdensity
fi

exit ${rc}
