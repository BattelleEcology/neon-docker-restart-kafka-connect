#!/usr/bin/env sh
# Set the environment variable CONNECT_URL to the url of the kafka connnect API
# before running this script. Otherwise it defaults to http://localhost:8083
# CONNECT_URL="http://localhost:8083"
connect_url=${CONNECT_URL:-http://localhost:8083}
connect_url="${connect_url}/connectors"
sleep_seconds="${RESTART_SLEEP_SECONDS:-900}"
echo "Entering restart loop with sleep set to ${sleep_seconds} seconds"
while true; do
curl -fsSL \
    --retry 10 \
    --connect-timeout 60 \
    "${connect_url}?expand=status" | \
jq -r -c -M 'map({name: .status.name } +  {tasks: .status.tasks}) |
          .[] |
          {task: ((.tasks[]) + {name: .name})} |
          (.task.name, (.task.id|tostring), .task.state)' |
while IFS= read -r task; do
  IFS= read -r taskid
  IFS= read -r state
  echo "Task: ${task} id: ${taskid} state: ${state}"
  if [ "${state}" = "RUNNING" ]; then
    echo "Task Running, not restarting"
  else
    echo "Restarting task: ${task} id: ${taskid}"
        CODE=$(curl -fsSL \
                -w '%{http_code}' \
                --retry 10 \
                --connect-timeout 60 \
                -X POST \
                "${connect_url}/${task}/tasks/${taskid}/restart")
        if [ "$CODE" = "204" ]; then
            echo "Restart successful"
        else
            echo "Restart failed, return code: ${CODE}. Exiting."
            exit 1
        fi
    fi
done
echo "Sleeping ${sleep_seconds} seconds"
sleep "$sleep_seconds"
done