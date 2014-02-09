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
export HAS_NETWORKING=0

export TABCMD_DIR=/usr/local/tabcmd

cd ~/

install_package() {
	if [ "$(dpkg -l $1 | tail -n1 | grep ii | grep $1 | awk '{print $1"_"$2}')" == "ii_$1" ]; then
		echo ruby1.9.1 is already installed
	else
		echo "install_package() installing."
		[ "$HAS_NETWORKING" == "0" ] && {
	  		echo "install_package() requires networking."
	  		exit $EXIT_ERROR
	  	}
	  	echo "Installing $1"
	  	apt-get install $1 -y || {
	  		echo "failed to install $1";
	  		exit $EXIT_ERROR
	  	}
	  	echo "Package $1 is installed"
	  	for i in $(seq 5 -1 1);  do echo -n " $i "; sleep 1; done; echo " GO! "
	  	echo "install_package() finished."
	fi
	return 0
}

#
# Initial prompts and confirmations.
#
[ "$(whoami)" != "root" ] && {
	echo "This file must be executed as root (or through sudo)." 
	exit $EXIT_ERROR
}
ping -c1 8.8.8.8 &> /dev/null
[ "$?" == "0" ] && export HAS_NETWORKING=1

echo "$0 starting..."
echo "-------------------------------------------------------------------"
echo "(c) 2014 Sam Caldwell.  See https://github.com/x684867/tabcmd_linux"
echo "-------------------------------------------------------------------"
echo " "
echo "This script will configure a brand new Ubuntu Linux installation for use with tabcmd?"
echo " " 
read -p "Is this what you want to do? (y/n)" ANSWER
[ $(echo "$ANSWER" | tr yn YN | tr -dc YN) != "Y" ] && {
	echo "Cancelled.";
	exit $EXIT_CANCEL
}
echo " "
read -p "Do you have a valid Tableau Server license? (y/n)" ANSWER
[ $(echo "$ANSWER" | tr yn YN | tr -dc YN) != "Y" ] && {
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
read -p "Have you uploaded tabcmd.jar to this server? (y/n)" ANSWER 
while [ $(echo "$ANSWER" | tr yn YN | tr -dc YN) != "Y" ]; do
  echo "Don't worry, the script will wait right here until you are finished...."
  echo " "
  read -p "Have you uploaded tabcmd.jar to this server? (y/n)" ANSWER 
  echo " "
done
echo " "
ANSWER="N"
while [ $(echo "$ANSWER" | tr yn YN | tr -dc YN) != "Y" ]; do
	echo "Where did you upload the tabcmd.jar file (\$path/tabcmd.jar)?"
	read -p "Enter path: " UPLOAD_PATH
    echo " "
    if [ -z "$UPLOAD_PATH" ]; then
      echo "No UPLOAD_PATH specified.  Try again."
      ANSWER="N"
	else
      echo "Verifying the file/path..."

      if [ -f $UPLOAD_PATH ]; then
        ANSWER="Y"
        cp $UPLOAD_PATH /tmp/tabcmd.jar
      else
        echo "Could not find the file...please investigate and the script will retry."
        ANSWER="N"
      fi
    fi
done
echo " "
echo "Excellent....  We are ready to proceed."
echo " "
#
# Start setting up the prerequisites.
#
echo " "
echo "Installing prerequisites..."
echo " "
echo "    Installing ruby1.9.1"
install_package ruby1.9.1
install_package ruby1.9.1-dev
echo " "
echo "    Installing ruby-rvm"
echo " "
install_package ruby-rvm
echo " "
echo "    Installing unzip"
echo " "
install_package unzip 
echo " " 
echo "Prerequisites are installed."
echo " "
echo "Creating $TABCMD_DIR"
[ ! -d $TABCMD_DIR ] && rm -rf $TABCMD_DIR
mkdir -p $TABCMD_DIR || {
	echo "Failed to create $TABCMD_DIR"; 
	exit $EXIT_ERROR
}
echo "checking..."
[ ! -d $TABCMD_DIR ] && echo "Verification failed for ($TABCMD_DIR)"
echo " "
echo "Moving tabcmd.jar into $TABCMD_DIR"
[ ! -f /tmp/tabcmd.jar ] && echo "Could not find /tmp/tabcmd.jar" && exit $EXIT_ERROR
[ -f $TABCMD_DIR/tabcmd.jar ] && rm $TABCMD_DIR/tabcmd.jar 
mv /tmp/tabcmd.jar $TABCMD_DIR || {
	echo "move failed."; 
	exit $EXIT_ERROR
}
cd $TABCMD_DIR
unzip $TABCMD_DIR/tabcmd.jar
cd $TABCMD_DIR/
echo "Current Directory: $(pwd)"
echo " "
echo "Installing Ruby Gems"
echo " "
gem update
gem install abstract && \
gem install bundler && \
gem install rake && \
gem install rack && \
gem install unit_record && \
gem install treetop && \
gem install thor && \
gem install rubyzip && \
gem install rack-test && \
gem install rack-mount && \
gem install highline && \
gem install builder && \
gem install log4r && \
gem install columnize && \
gem install erubis && \
gem install json_pure && \
gem install jruby-openssl && \
gem install i18n && \
gem install mail && \
gem install mime-types && \
gem install polyglot && \
gem install arel && \
gem install gem_plugin && \
gem install rchardet && \
gem install sources && \
gem install actionmailer && \
gem install actionpack && \
gem install activesupport && \
gem install activemodel && \
gem install activeresource && \
gem install rails && \
gem install railties && \
gem install ruby-debug19 && \
gem install hpricot
echo " "
echo "Gems Installed."
echo " " 
echo "------------------------------"
echo " Gem List"
echo "------------------------------"
gem list
echo "------------------------------"
echo " $(date)"
echo "------------------------------"

