cd "$(dirname "$0")"
DURATION=2m k6 run --no-color slo-test.js > results/chaos.txt 2>&1 &
K6=$!
sleep 45
PID=$(netstat -ano | grep ':3000 ' | grep LISTENING | awk '{print $5}' | head -1)
echo "$(date +%T) killing server pid=$PID" > results/chaos-log.txt
taskkill //PID $PID //F >> results/chaos-log.txt 2>&1
sleep 10
(node server.js > /dev/null 2>&1 &)
echo "$(date +%T) server restarted" >> results/chaos-log.txt
wait $K6; echo "k6 exit=$?" >> results/chaos-log.txt
