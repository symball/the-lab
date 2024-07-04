red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

#
# HALT
#
# Safe method for stopping dev environment. If running the main
# process in foreground, will also shutdown services
#
halt() {
  echo "${red}--=== HALTING ===--${reset}"
  echo ""
  echo "${green}$1${reset}"
  exit 1
}

spacer() {
  message="***"
  if [[ $# -eq 1 ]] ; then
    message=$1
  fi
  echo ""
  echo "---=== ${message} ===---"
  echo ""
}
trap halt SIGHUP SIGINT SIGTERM

command_exists() {
  if command -v $1 &>/dev/null
    then return 0
    else return 1
  fi
}

path_exists() {
  if [ -d $1 ]
    then return 0
    else return 1
  fi
}

ok() {
  echo -e " ${green}OK${reset}"
}