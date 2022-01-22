# kill polybar instances
pkill polybar

# Wait until the processes have been shut down
#while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
sleep 1

rm /tmp/polybar*
rm /tmp/ipc-polybar


polybar $CONFIG --reload example

# Launch polybar on all monitors
# for m in $(polybar --list-monitors | cut -d":" -f1); do
#   MONITOR=$m polybar $CONFIG --reload example &
# done
