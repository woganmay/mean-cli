#!/usr/bin/env bash
set -u 
set -e
set -x


set_env1(){
export dir_product=/tmp/session
export dir_artifacts=${CIRCLE_ARTIFACTS:-$HOME}
}
ensure1(){
test -d $dir_product || { mkdir -p $dir_product; }
}
apt0(){
sudo apt-get install -y -q <<START1
xcowsay  libnotify-bin imagemagick
xvfb x11-utils x11-apps dbus-x11  
START1
}
print_single(){
local file=$1
node <<START2
require("image-to-ascii")("$file", function (err, result) {
    console.log(result);
})
START2
}

print_many(){
  local list=$( ls -1 $dir_product/*sh )
    for item in $list;do
    file=$dir_product/$item
    test -f $file
    print_single $file
    done


}

apt1(){  
#firefox
commander sudo apt-get -y -q update
npm install -g image-to-ascii

commander sudo apt-get install -y -q xvfb x11-utils x11-apps   dbus-x11 
commander sudo apt-get install -y -q graphicsmagick  
commander sudo apt-get install -y -q xcowsay   libnotify-bin firefox imagemagick
}


capture1(){
  local file="$dir_product/session_$(date +%s).png"
  commander "import -window root $file"
}
capture2(){
  local file
  
  while true;do
  file="$dir_product/session_$(date +%s).png"
  eval "import -window root $file"
  sleep 1
  done
}

debug_screen(){
#commander xwininfo -root -tree
/usr/games/xcowsay -t 3  "x11 test" &
firefox &
}

ensure_apt(){
commander which xcowsay 
commander whereis xcowsay 
}

steps(){
  set_env1
  ensure1
  #apt0
  apt1
  ensure_apt
  
  debug_screen
  capture2 &
  sleep 5
  print_many
  cp $dir_product/*.png $dir_artifacts
}

steps
