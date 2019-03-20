#!/bin/bash


usage()
{
	echo ""
	echo "Usage: `basename $0` [option] "
	echo "Options:"
	echo "  y | -y "
	echo "      Automatic install all packages with non-interactively. "
	echo "  -h, --help:"
	echo "      Print this message and exit."
	echo ""
	echo "this script only have one option"
	exit 0
}
ANSWER=0
if [ $# -eq 1 ]; then 
	case $1 in
		--yes | -y)
			ANSWER=1
				;;
			printf "all packages will install Automatic"
		--help | -h) usage
			;;
		*) echo "illegal option $i"
			usage
			;;
	esac
else
	usage
fi


#sudo docker run -it -v /home/xiao/fibjs:/ci crossenv:2 /bin/bash -c "cd /ci && sh build release ppc"
