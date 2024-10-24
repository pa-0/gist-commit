alias wanip='dig +short myip.opendns.com @resolver1.opendns.com'
alias lanip='_lanip | column -t'
function _lanip(){

for dev in $(ls /sys/class/net); do
  echo -n $dev " "
  net=$(ip -f inet addr show $dev | grep --color=never -Po 'inet \K[\d.]+?\/\d+')
  if [[ -n $net ]]; then
    echo -n $net
  else
    echo -n 'nil'
  fi
  echo -n "\t"
  mac=$(ip -f link addr show $dev | grep --color=never -Po 'link/[\w\d]+\s*\K[\da-f]{2}(:[\da-f]{2}){5}');

  if [[ -n $mac ]] && [ "$mac" != "00:00:00:00:00:00" ]; then
    echo -n  $mac
  else
    echo -n 'nil'
  fi
  echo
done
}
