# kill polybar instances
pkill polybar

# Wait until the processes have been shut down
#while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
sleep 1

rm /tmp/polybar*
rm /tmp/ipc-polybar

largest_height=0
largest_config=""
largest_name=""

while IFS= read -r monitor; do  
  height=$(echo $monitor | grep -oP "x\K([[:digit:]]{3,4})")

  if [[ $(echo "$height > 2000" | bc -l) -eq 1 ]]; then
    config_name="large"
  elif [[ $(echo "$height > 1000" | bc -l) -eq 1 ]]; then
    config_name="medium"
  else
    config_name="medium"
  fi

  if [[ $(echo "$height > $largest_height" | bc -l) -eq 1 ]]; then
    largest_height=$height
    largest_name=$(echo $monitor | grep -oP "(.+):" | grep -oE ".*[^:]")
    largest_config=$config_name
  fi

done < <(polybar --list-monitors)

MONITOR=$largest_name polybar --reload $largest_config &
