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
  extension=$(echo "$fileName" | rev | cut -f 1 -d '.' | rev )

  echo "$extension"
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

    # Set png backgroud image as default lock screen
    if [ $extension == 'png' ]
    then
      gksu cp "$file" /usr/share/backgrounds/warty-final-ubuntu.png
    else
      # If image not png, try to create converted png copy using morgify
      # morgify will overwrite file if it already exists, must check before creating
      echo "WARNING: $fileName is not a valid png file and cannot be set as lock screen background."

      # Get filename without extension
      withoutExt=$(echo "$file" | cut -f 1 -d '.')
      withoutExtFN=$(echo "$fileName" | cut -f 1 -d '.')
      echo "WARNING: Will try to create $withoutExtFN.png and set it as lock screen background."

      # Check if png file already exists
      if [ -f "$withoutExt.png" ];
      then
        # Don't overwrite
        echo "WARNING: File $withoutExtFN.png already exists, will not overwritte."
        echo "WARNING: Setting $withoutExtFN.png as lock screen background."
        gksu cp "$withoutExt.png" /usr/share/backgrounds/warty-final-ubuntu.png
      else
        # Doesn't exist, create png and set lock screen background
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
