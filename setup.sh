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
export EXIT_NONROOT=3
export EXIT_GITHUBFAILED=4
export EXIT_MISSINGFILE=5
export HAS_NETWORKING=0

[ "$(whoami)" != "root" ] && echo "$0 must be run as root." && exit $EXIT_NONROOT
apt-get install git-core -y &> /dev/null

echo "Starting..."
cd ~/
git clone https://github.com/x684867/tabcmd_linux
[ "$?" != "0" ] && {
	echo "cloning latest scripts from github failed."
	exit $EXIT_GITHUBFAILED
}
[ ! -f ~/install.sh ] && {
	echo "Failed to download ~/install.sh
	exit $EXIT_MISSINGFILE
}
[ ! -x ~/install.sh ] && {
	chmod +x ~/install.sh
	[ ! -x ~/install.sh ] && {
		echo "~/install.sh is not executable."
		exit $EXIT_ERROR
	}
}
cd ~/
./install