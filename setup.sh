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
echo "$0 starting..."

[ "$(whoami)" != "root" ] && {
	echo "This file must be executed as root (or through sudo)." 
	exit $EXIT_ERROR
}
ping -c1 8.8.8.8 &> /dev/null
[ "$?" == "0" ] && {
	export HAS_NETWORKING=1
}
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
echo "    Installing git core to get the assets we need from this project."
echo " "
install_package git-core
echo " "

echo "    Installing unzip"
echo " "
install_package unzip 
echo " "
echo "    Installing ruby1.9.1"
install_package ruby1.9.1 && \
install_package ruby1.9.1-dev && \
install_package rubygems1.9.1 && \
install_package irb1.9.1 && \
install_package ri1.9.1 && \
install_package rdoc1.9.1 && \
install_package build-essential && \
install_package libopenssl-ruby1.9.1 && \
install_package libssl-dev && \
install_package zlib1g-dev -y && \
ruby --version
echo "Packages are installed."
echo " "
echo " "
echo "   Configuring Ruby."
sudo update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby1.9.1 400 \
         --slave   /usr/share/man/man1/ruby.1.gz ruby.1.gz \
                        /usr/share/man/man1/ruby1.9.1.1.gz \
        --slave   /usr/bin/ri ri /usr/bin/ri1.9.1 \
        --slave   /usr/bin/irb irb /usr/bin/irb1.9.1 \
        --slave   /usr/bin/rdoc rdoc /usr/bin/rdoc1.9.1 && \
sudo update-alternatives --config ruby && \
sudo update-alternatives --config gem || {
	echo "Failed to update-alternatives for ruby"
	exit $EXIT_ERROR
}
echo " "
echo "    Installing ruby-rvm"
echo " "
install_package ruby-rvm
echo " "
echo "    Installing Java Run-time Environment (JRE) 6u45)"
cd ~/
git clone https://github.com/x684867/tabcmd_linux
cd tabcmd_linux
[ ! -f jre-6u45-linux-x64.bin ] && echo "missing jre-6u45-linux-x64.bin" && exit $EXIT_ERROR
[ ! -x jre-6u45-linux-x64.bin ] && chmod +x jre-6u45-linux-x64.bin
[ ! -x jre-6u45-linux-x64.bin ] && echo "could not make jre-6u45-linux-x64.bin executable" && exit $EXIT_ERROR
echo "Ready to install JAVA (jre-6u45-linux-x64.bin)"
./jre-6u45-linux-x64.bin || {
	echo "Failed to install jre-6u45-linux-x64.bin"
	exit $EXIT_ERROR
}

[ ! -d jre1.6.0_45 ] && echo "could not find ~/jre1.6.0_45/" && exit $EXIT_ERROR
[ -d /usr/java ] && rm -rf /usr/java && echo "deleted /usr/java"
[ ! -d /usr/java ] && mkdir /usr/java && echo "re-created /usr/java"
[ ! -d /usr/java ] && echo "/usr/java could not be created" && exit $EXIT_ERROR

mv jre1.6.0_45/ /usr/java/

[ ! -d /usr/java/jre1.6.0_45 ] && echo "/usr/java/jre1.6.0_45/ was not moved successfully." && exit $EXIT_ERROR

echo "creating /usr/java/current => /usr/java/jre1.6.0_45 symlink"
ln -s /usr/java/jre1.6.0_45/ /usr/java/current

[ -d /usr/share/java ] && rm -rf /usr/share/java
[ ! -d /usr/share/java ] && ln -s /usr/java /usr/share/java
echo "/usr/share/java => /usr/java/ symlink created."

echo "Setting JAVA_HOME and adding JAVA_HOME/bin to PATH."
echo "export JAVA_HOME=/usr/java/current" >> /etc/profile
echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> /etc/profile
echo " "
echo "re-sourcing /etc/profile"
echo " "
source /etc/profile
java -version || {
	echo "Java failed to install correctly!"
	exit $EXIT_ERROR
}
echo " "
echo "    Installing jruby"
echo " "
install_package jruby
echo " "
echo " " 
echo "Prerequisites are installed."
echo " "
echo "Purging Previous Install."
[ ! -d $TABCMD_DIR ] && rm -rf $TABCMD_DIR
echo "Creating $TABCMD_DIR"
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
gem update && \
rvm install jruby
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
gem install hpricot || {
	echo "One or more GEMS failed to install" 
	exit $EXIT_ERROR
}
echo "Gems Installed."
echo " " 
echo "------------------------------"
echo " Gem List"
echo "------------------------------"
gem list
echo "------------------------------"
echo " $(date)"
echo "------------------------------"
echo " "
echo "Remove tabutil.rb ($TABCMD_DIR)"
[ -f "$TABCMD_DIR/tabcmd/common/ruby/lib/tabutil.rb" ] && rm $TABCMD_DIR/tabcmd/common/ruby/lib/tabutil.rb
[ -f "$TABCMD_DIR/tabcmd/common/ruby/lib/tabutil.rb" ] && {
	echo "Failed to delete tabutil.rb"
	exit $EXIT_ERROR
}
echo " " 
echo "creating dump_reporter.rb ($TABCMD_DIR)"
echo " " 
cat >$TABCMD_DIR/tabcmd/common/ruby/lib/dump_reporter.rb << EOF
#require 'tabutil'
#Modified by tabcmd_linux/setup.sh
class DumpReporter
  def initialize(app_name, log_dir, exit_on_exception)
  end
  def self.setup(app_name, log_dir, exit_on_exception)
    $dump_reporter = DumpReporter.new(app_name, log_dir, exit_on_exception)
  end
  def self.force_crash
  end
end
EOF
[ ! -f "$TABCMD_DIR/tabcmd/common/ruby/lib/dump_reporter.rb" ] && {
	echo "Failed to create dump_reporter.rb"
	exit $EXIT_ERROR
}
echo " " 
echo "Setup Environment"
echo " "
echo "export TABCMD_DIR=$TABCMD_DIR" >> /etc/profile
echo "export RUBY_LIB=$TABCMD_DIR/tabcmd/lib" >> /etc/profile
source /etc/profile
echo " "
echo "Make the tabcmd.rb file executable"
chmod +x /usr/local/tabcmd/tabcmd/bin/tabcmd.rb 
echo " "
echo "Substitute pathing in ../bin/tabcmd.rb to use our installation paths."
echo " "
#REPLACES ENTRIES
sed -i -e 's/\$LOAD_PATH << File\.expand_path(.*\/common\/ruby\/lib.*/COMMON_LIB_PLACEHOLDER/' /usr/local/tabcmd/tabcmd/bin/tabcmd.rb
sed -i -e 's/require File\.expand_path(.*$/TABCMD_LIB_PLACEHOLDER/' /usr/local/tabcmd/tabcmd/bin/tabcmd.rb
sed -i -e 's/\$LOAD_PATH << File\.expand_path(.*\/lib.*/TABCMD_LIB_DIR_PLACEHOLDER/' /usr/local/tabcmd/tabcmd/bin/tabcmd.rb
#RECONFIGURE THE ENTRIES
sed -i -e "s/COMMON_LIB_PLACEHOLDER/\$LOAD_PATH << File\.expand_path(\'$TABCMD_DIR\/tabcmd\/common\/ruby\/lib\')/" /usr/local/tabcmd/tabcmd/bin/tabcmd.rb
sed -i -e "s/TABCMD_LIB_PLACEHOLDER/\$LOAD_PATH << File\.expand_path(\'$TABCMD_DIR\/tabcmd\/lib\/tabcmd.rb')/" /usr/local/tabcmd/tabcmd/bin/tabcmd.rb
sed -i -e "s/TABCMD_LIB_DIR_PLACEHOLDER/\$LOAD_PATH << File\.expand_path(\'$TABCMD_DIR\/tabcmd\/lib\')/" /usr/local/tabcmd/tabcmd/bin/tabcmd.rb
echo " "
echo "Done.  Pathing is fixed."
echo " "


