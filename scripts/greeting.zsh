# Local-only dashboard; sourced by Home Manager's interactive zsh configuration.
den_welcome() {
  [[ -o interactive && -o login ]] || return
  emulate -L zsh
  setopt localoptions no_shwordsplit
  local os=$(uname -s) platform arch=$(uname -m)
  local uptime_text='unavailable' disk_text='unavailable' battery_text=''
  local config_text='unavailable' activation_text='not recorded' warning=''
  local value boot now=$EPOCHSECONDS age minutes days hours percent free_kib used
  local repo="$HOME/.config/den" changes line count=0
  local amber='' reset=''
  if [[ -t 1 && -z ${NO_COLOR+x} && $TERM != dumb ]]; then
    amber=$'\e[33m'; reset=$'\e[0m'
  fi

  case $os in
    Darwin)
      platform="macOS $(/usr/bin/sw_vers -productVersion 2>/dev/null)"
      value=$(/usr/sbin/sysctl -n kern.boottime 2>/dev/null)
      boot=${${value#*sec = }%%,*}
      value=$(/usr/bin/pmset -g batt 2>/dev/null)
      if [[ $value =~ '([0-9]+)%' ]]; then
        percent=$match[1]
        battery_text=" · battery ${percent}%"
        if [[ $value == *'AC Power'* ]]; then
          battery_text+=' ⚡'
        elif (( percent < 20 )); then
          warning='battery running low'
        fi
      fi
      ;;
    Linux)
      platform='Linux'
      if [[ -r /proc/uptime ]]; then
        read -r value _ < /proc/uptime
        boot=$(( now - ${value%%.*} ))
      fi
      ;;
    *) platform=$os ;;
  esac
  if [[ $boot == <-> ]] && (( now >= boot )); then
    minutes=$(( (now - boot) / 60 ))
    days=$(( minutes / 1440 )); hours=$(( minutes / 60 % 24 ))
    uptime_text="${days}d ${hours}h"
    (( days == 0 )) && uptime_text="${hours}h $(( minutes % 60 ))m"
  fi

  value=$(LC_ALL=C df -Pk "$HOME" 2>/dev/null | tail -n 1)
  local -a fields=( ${=value} )
  free_kib=$fields[4]; used=${fields[5]%\%}
  if [[ $free_kib == <-> && $used == <-> ]]; then
    disk_text="$(( free_kib / 1048576 )) GiB free"
    if (( used >= 90 )); then
      warning="${warning:+$warning · }disk space running low"
    fi
  fi

  if changes=$(GIT_OPTIONAL_LOCKS=0 git -C "$repo" status --porcelain --untracked-files=normal 2>/dev/null); then
    if [[ -z $changes ]]; then
      config_text='✓ clean'
    else
      for line in "${(@f)changes}"; do (( count += 1 )); done
      config_text="${count} changed entries"
    fi
  fi
  if [[ -r /var/db/den/last-activation ]]; then
    read -r value < /var/db/den/last-activation
    if [[ $value == <-> ]] && (( now >= value )); then
      age=$(( now - value ))
      if (( age < 60 )); then activation_text='just now'
      elif (( age < 3600 )); then activation_text="$(( age / 60 ))m ago"
      elif (( age < 86400 )); then activation_text="$(( age / 3600 ))h ago"
      else activation_text="$(( age / 86400 ))d ago"
      fi
    fi
  fi

  printf '╭─ den\n'
  printf '│ %s · %s · zsh %s\n' "$platform" "$arch" "$ZSH_VERSION"
  printf '│ ↑ %s · disk %s%s\n' "$uptime_text" "$disk_text" "$battery_text"
  printf '│ config %s · last activation %s\n' "$config_text" "$activation_text"
  if [[ -n $warning ]]; then
    printf '╰─ %s%s%s\n' "$amber" "$warning" "$reset"
  else
    printf '╰─ ready\n'
  fi
}
zmodload zsh/datetime
den_welcome
unfunction den_welcome
