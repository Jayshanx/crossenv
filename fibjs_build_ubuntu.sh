#!/bin/bash


# this script is to create a fibjs cross-compile envirment using clang on ubuntu.
# reference to eos_build_ubuntu.sh at https://github.com/EOSIO/eos/blob/master/scripts/eosio_build_ubuntu.sh.
# read more about How To Cross-compilation using Clang at https://llvm.org/docs/HowToCrossCompileLLVM.html and http://clang.llvm.org/docs/CrossCompilation.html.
# We recommend that you use docker because this script will install some software on your computer.

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
	echo "this script should one or zero option"
	exit 0
}

ANSWER=0
if [ $# -eq 1 ]; then 
	case $1 in
		--yes | -y)
			ANSWER=1
			printf "all packages will install Automatic"
			;;
		--help | -h) usage
			;;
		*) echo "illegal option $i"
			usage
			;;
	esac
fi

#ANSWER='-y'
OS_VER=$( grep VERSION_ID /etc/os-release | cut -d'=' -f2 | sed 's/[^0-9\.]//gI' )
OS_MAJ=$(echo "${OS_VER}" | cut -d'.' -f1)
OS_MIN=$(echo "${OS_VER}" | cut -d'.' -f2)

MEM_MEG=$( free -m | sed -n 2p | tr -s ' ' | cut -d\  -f2 || cut -d' ' -f2 )
CPU_SPEED=$( lscpu | grep -m1 "MHz" | tr -s ' ' | cut -d\  -f3 || cut -d' ' -f3 | cut -d'.' -f1 )
CPU_CORE=$( nproc )
MEM_GIG=$(( ((MEM_MEG / 1000) / 2) ))
export JOBS=$(( MEM_GIG > CPU_CORE ? CPU_CORE : MEM_GIG ))

DISK_INSTALL=$(df -h . | tail -1 | tr -s ' ' | cut -d\  -f1 || cut -d' ' -f1)
DISK_TOTAL_KB=$(df . | tail -1 | awk '{print $2}')
DISK_AVAIL_KB=$(df . | tail -1 | awk '{print $4}')
DISK_TOTAL=$(( DISK_TOTAL_KB / 1048576 ))
DISK_AVAIL=$(( DISK_AVAIL_KB / 1048576 ))

printf "\\nOS name: ${OS_NAME}\\n"
printf "OS Version: ${OS_VER}\\n"
printf "CPU speed: ${CPU_SPEED}Mhz\\n"
printf "CPU cores: %s\\n" "${CPU_CORE}"
printf "Physical Memory: ${MEM_MEG} Mgb\\n"
printf "Disk install: ${DISK_INSTALL}\\n"
printf "Disk space total: ${DISK_TOTAL%.*}G\\n"
printf "Disk space available: ${DISK_AVAIL%.*}G\\n"

# if [ "${MEM_MEG}" -lt 3000 ]; then
# 	printf "Your system must have 3 or more Gigabytes of physical memory installed.\\n"
# 	printf "Exiting now.\\n"
# 	exit 1
# fi

if [ "${OS_MAJ}" -lt 16 ]; then
	printf "You must be running Ubuntu 16.04.x or higher to install fibjs.\\n"
	printf "Exiting now.\\n"
	exit 1
fi

DEP_ARRAY=(make cmake git llvm-6.0 clang-6.0 clang++-6.0 build-essential)

CROSS_DEP=(g++-5-mips-linux-gnu g++-5-mips64-linux-gnuabi64 g++-5-powerpc-linux-gnu g++-5-powerpc64-linux-gnu g++-5-arm-linux-gnueabihf g++-5-aarch64-linux-gnu)

COUNT=1
DISPLAY=""
DEP=""

# llvm source
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - 
apt-get update
if [ "${OS_MAJ}" -eq 16 ]; then
	apt-add-repository "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-6.0 main"
else
	apt-add-repository "deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-6.0 main"
fi

if [ $ANSWER != 1 ]; then read -p "Do you wish to update repositories with apt-get update? (y/n) " ANSWER; fi
case $ANSWER in
	1 | [Yy]* )
		if ! apt-get update; then
			printf " - APT update failed.\\n"
			exit 1;
		else
			printf " - APT update complete.\\n"
		fi
	;;
	[Nn]* ) echo "Proceeding without update!";;
	* ) echo "Please type 'y' for yes or 'n' for no."; exit;;
esac

# install essential packages
printf "\\nChecking for installed dependencies...\\n"
for (( i=0; i<${#DEP_ARRAY[@]}; i++ )); do
	pkg=$( dpkg -s "${DEP_ARRAY[$i]}" 2>/dev/null | grep Status | tr -s ' ' | cut -d\  -f4 )
	if [ -z "$pkg" ]; then
		DEP=$DEP" ${DEP_ARRAY[$i]} "
		DISPLAY="${DISPLAY}${COUNT}. ${DEP_ARRAY[$i]}\\n"
		printf " - Package %s${bldred} NOT${txtrst} found!\\n" "${DEP_ARRAY[$i]}"
		(( COUNT++ ))
	else
		printf " - Package %s found.\\n" "${DEP_ARRAY[$i]}"
		continue
	fi
done

if [ "${COUNT}" -gt 1 ]; then
	printf "\\nThe following dependencies are required to install fibjs:\\n"
	printf "${DISPLAY}\\n\\n" 
	if [ $ANSWER != 1 ]; then read -p "Do you wish to install these packages? (y/n) " ANSWER; fi
	case $ANSWER in
		1 | [Yy]* )
			if ! apt-get -y install ${DEP}; then
				printf " - APT dependency failed.\\n"
				exit 1
			else
				printf " - APT dependencies installed successfully.\\n"
			fi
		;;
		[Nn]* ) echo "User aborting installation of required dependencies, Exiting now."; exit;;
		* ) echo "Please type 'y' for yes or 'n' for no."; exit;;
	esac
else 
	printf " - No required APT dependencies to install."
fi

printf "\\n"

DEP=""

# install toolchains
printf "\\nThe following are toolchain packages if you are trying to crossing-compile:\\n"
for (( i=0; i<${#CROSS_DEP[@]}; i++ )); do
	printf " - ${CROSS_DEP[$i]} \n "
	DEP=$DEP" ${CROSS_DEP[$i]} "
done

if [ $ANSWER != 1 ]; then read -p "Do you wish to install these packages? (y/n) " ANSWER; fi
case $ANSWER in
	1 | [Yy]* )
		if ! apt-get  -y  install ${DEP}; then
			printf " - APT dependency failed.\\n"
			exit 1
		else
			printf " - APT dependencies installed successfully.\\n"
		fi
	;;
	[Nn]* ) echo "User aborting installation of required dependencies, Exiting now."; exit;;
	* ) echo "Please type 'y' for yes or 'n' for no."; exit;;
esac

update-alternatives --install /usr/bin/clang clang /usr/bin/clang-6.0 999
update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-6.0 999

for v in ${CROSS_DEP[@]};do
	update-alternatives --install /usr/bin/${v:6}-gcc ${v:6}-gcc /usr/bin/${v:6}-gcc-5 999
	update-alternatives --install /usr/bin/${v:6}-g++ ${v:6}-g++ /usr/bin/${v:6}-g++-5 999
done

apt-get clean
rm -rf /var/lib/apt/lists/*  /usr/share/doc /usr/share/man
printf "\\n the fibjs enviroment has been successfully setting\\n"
