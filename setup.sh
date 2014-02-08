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

#
# Initial prompts and confirmations.
#

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
done
echo "connect to the Tableau Server and find the Tabcmd installer within your"
echo "server environment, install tabcmd to your server or another compatible"
echo "machine.  Then obtain tabcmd.jar from within the tabcmd directory."
echo " "
echo 
echo "ta
#
# Start setting up the prerequisites.
#
apt-get install ruby1.9.1 -y && \
apt-get install ruby-rvm -y && \
apt-get install 



