#!/bin/bash
set -xe

for f in /app/lib/*.sh; do 
    source $f; 
done

if [ "$ACTION" = "redeploy" ] || [ "$ACTION" = "upgrade" ] || [ "$ACTION" == "uninstall" ]; then
    prepare_helm_chart
fi

if ( [ "$ACTION" = "redeploy" ] || [ "$ACTION" = "upgrade" ] ) && [ "$SECURITY_CHECK" = "enable" ]; then
    security_check
fi

if [ "$ACTION" = "upgrade" ]; then
    remove_old_jobs
fi

if [ "$ACTION" = "uninstall" ] || [ "$ACTION" = "redeploy" ]; then
    uninstall
fi

if [ "$ACTION" = "redeploy" ] || [ "$ACTION" = "upgrade" ]; then
    deploy
    update_project_description
fi

if [ "$UPDATE_DOCS" = "enable" ]; then
    update_default_docs_and_configs
fi
