# kill polybar instances
pkill polybar

# Wait until the processes have been shut down
#while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
sleep 1

rm /tmp/polybar*
rm /tmp/ipc-polybar

# max_height=""
# primary_name=""
# primary_name=""

# for monitor in $(polybar --list-monitors | grep -oP "[[:digit:]]{3,4}x[[:digit:]]{3,4}"); do
#   height=$(echo $monitor | grep -oP "x\K([[:digit:]]{3,4})")
#   name=$(echo $monitor | grep -oP "(.+):" | grep -oE ".*[^:]")
#
#   if [[ $(echo "$height > 2000" | bc -l) -eq 1 ]]; then
#     config_name="large"
#   elif [[ $(echo "$height > 1000" | bc -l) -eq 1 ]]; then
#     config_name="medium"
#   else
#     config_name="medium"
#   fi
# done

# MONITOR=$primary_name polybar --reload $config_name &

polybar --reload large &
