#!/bin/bash
#
#	The MIT License (MIT)
#	Copyright (c) 2014 Sam Caldwell.
#	
#	Permission is hereby granted, free of charge, to any person obtaining a copy
#	of this software and associated documentation files (the "Software"), to deal
#	in the Software without restriction, including without limitation the rights
#	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#	copies of the Software, and to permit persons to whom the Software is
#	furnished to do so, subject to the following conditions:
#	
#	The above copyright notice and this permission notice shall be included in
#	all copies or substantial portions of the Software.
#
#	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#	THE SOFTWARE.	
#
export EXIT_SUCCESS=0
export EXIT_CANCEL=1
export EXIT_ERROR=2

export TABCMD_DIR=/usr/local/tabcmd


#
# Initial prompts and confirmations.
#
[ "$(whoami)" != "root" ] && echo "This file must be executed as root (or through sudo)." && EXIT_ERROR
echo "$0 starting..."
echo "-------------------------------------------------------------------"
echo "(c) 2014 Sam Caldwell.  See https://github.com/x684867/tabcmd_linux"
echo "-------------------------------------------------------------------"
echo " "
echo "This script will configure a brand new Ubuntu Linux installation for use with tabcmd?"
echo " " 
read -p "Is this what you want to do? (y/n)" ANSWER
[ $(echo "$ANSWER" | tr yn YN | tr -dc YN) != "Y"] && echo "Cancelled." && exit $EXIT_CANCEL
echo " "
read -p "Do you have a valid Tableau Server license?" ANSWER
[ $(echo "$ANSWER" | tr yn YN | tr -dc YN) != "Y"] && {
  echo "Cancelled.  You must have a valid license to use this tool."
  exit $EXIT_CANCEL
}
echo " " 
echo "This script will require you to provide a copy of tabcmd.jar, which is"
echo "available in your Tableau Server installation.  To proceed, you must--"
echo " "
echo "   (1) Connect to the Tableau Server and find the Tabcmd Installer."
echo "   (2) Install tabcmd on the server or another compatible machine."
echo "   (3) Navigate to the directory where tabcmd.exe is located and find"
echo "       tabcmd.jar."
echo "   (4) Upload tabcmd.jar to this server using SFTP (FileZilla is a great"
echo "       tool for doing this."
echo " "
ANSWER="N"
while [ $(echo "$ANSWER" | tr yn YN | tr -dc YN) != "Y"]; do
  echo "Don't worry, the script will wait right here until you are finished...."
  echo " "
  read -p "Have you uploaded tabcmd.jar to this server? (y/n)" ANSWER 
  [ $(echo "$ANSWER" | tr yn YN | tr -dc YN) != "Y"] && {
    echo " " 
    echo "Where did you upload the tabcmd.jar file?"
    echo " "
    read -p "Enter path: " UPLOAD_PATH
    echo " "
    if [ -z "$UPLOAD_PATH" ]; then
      echo "Verifying the file/path..."
      
      if [ -d $UPLOAD_PATH ]; then 
        UPLOAD_PATH="$UPLOAD_PATH/tabcmd.jar"
      fi
      if [ -f $UPLOAD_PATH ]; then
        ANSWER="Y"
        mv $UPLOAD_PATH /tmp/tabcmd.jar
      else
        echo "Could not find the file...please investigate and the script will retry."
        ANSWER="N"
      fi
    else
      echo "No UPLOAD_PATH specified.  Try again."
      ANSWER="N"
    fi
  }
done
echo " "
echo "Excellent....  We are ready to proceed."
echo " "
#
# Start setting up the prerequisites.
#
install_package(){
  echo "Installing $1"
  apt-get install $1 -y || echo "failed to install $1" && exit EXIT_ERROR
  echo "Package $1 is installed"
  for i in $(seq 5 -1 1);  do echo -n " $i "; sleep 1; done; echo " GO! "
}

echo " "
echo "Installing ruby environment..."
echo " "
install_package ruby-1.9.1 && \
install_package ruby-rvm && \
install_package unzip && \
echo " " 
echo "Prerequisites are installed."
echo " "
echo "Creating $TABCMD_DIR"
mkdir $TABCMD_DIR || echo "Failed to create $TABCMD_DIR" && exit EXIT_ERROR
[ ! -d $TABCMD_DIR ] && echo "Verification failed for ($TABCMD_DIR)"
echo " "
echo "Moving tabcmd.jar into $TABCMD_DIR"
[ ! -f /tmp/tabcmd.jar ] && excho "Could not find /tmp/tabcmd.jar" && exit EXIT_ERROR
mv /tmp/tabcmd.jar $TABCMD_DIR || echo "move failed." && exit EXIT_ERROR
cd $TABCMD_DIR
