#!/bin/bash

if [ $# -lt 1 ]
then
  echo "Usage: set-lock-bg <image file>"
  echo "Help: set-lock-bg [-h][--help]"
  exit
fi

if [ "$1" == "-h" ] || [ "$1" == "--help" ]
then
  echo "help."
else
  file=$1
  fileName=$(echo "$file" | rev | cut -f 1 -d '/' | rev )

  # Check if file exists
  if [ -f "$file" ]
  then
    # Set background
    gsettings set org.gnome.desktop.background picture-uri "file://$file"
    if [ $? -eq 0 ]
    then
      echo "Successfully set $fileName as background."
    else
      exit
    fi

    # Create default lock screen background backup, if it doesn't already exist
    if ! [ -f "/usr/share/backgrounds/warty-final-ubuntu-backup.png" ]
    then
      sudo cp /usr/share/backgrounds/warty-final-ubuntu.png /usr/share/backgrounds/warty-final-ubuntu-backup.png
      if [ $? -eq 0 ]
      then
        echo "Created backup of /usr/share/backgrounds/warty-final-ubuntu.png"
      fi
    fi

    # If image not png, create converted copy
    # Set backgroud as default lock screen
    if [ "$file" == *.png ]
    then
      gksu cp "$file" /usr/share/backgrounds/warty-final-ubuntu.png
    else
      echo "WARNING: $fileName is not a valid png file and cannot be set as lock screen background."

      withoutExt=$(echo "$file" | cut -f 1 -d '.')
      withoutExtFN=$(echo "$fileName" | cut -f 1 -d '.')

      if [ -f "$withoutExt.png" ];
      then
         echo "WARNING: Will try to create $withoutExtFN.png and set it as lock screen background."
         echo "ERROR: Unable to create file $withoutExtFN.png because file already exist and would be overwritten."
         exit -1
      else
         mogrify -format png "$file"
         gksu mv "$withoutExt.png" "/usr/share/backgrounds/warty-final-ubuntu.png"
      fi
    fi

    if [ $? -eq 0 ]
    then
      echo "Successfully set $fileName as default lock screen background."
    fi
  else
  	echo "ERROR: File $fileName not set as lock screan background."
  fi
fi
