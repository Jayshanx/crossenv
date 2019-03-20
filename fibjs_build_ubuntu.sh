#!/bin/bash


# this script is to create a fibjs cross-compile envirment using clang
# reference to eos_build_ubuntu.sh  at https://github.com/EOSIO/eos/blob/master/scripts/eosio_build_ubuntu.sh
# read more about How To Cross-compilation using Clang at https://llvm.org/docs/HowToCrossCompileLLVM.html
# and http://clang.llvm.org/docs/CrossCompilation.html

#if [ $1 == 1 ]; then ANSWER=1; else ANSWER=0; fi
ANSWER=1
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

# if [ "${MEM_MEG}" -lt 7000 ]; then
# 	printf "Your system must have 7 or more Gigabytes of physical memory installed.\\n"
# 	printf "Exiting now.\\n"
# 	exit 1
# fi



if [ "${OS_MAJ}" -lt 16 ]; then
	printf "You must be running Ubuntu 16.04.x or higher to install fibjs.\\n"
	printf "Exiting now.\\n"
	exit 1
fi


# if [ "${DISK_AVAIL%.*}" -lt "${DISK_MIN}" ]; then
# 	printf "You must have at least %sGB of available storage to install EOSIO.\\n" "${DISK_MIN}"
# 	printf "Exiting now.\\n"
# 	exit 1
# fi

# defalut clang version on ubuntu 16.04 is 3.8 installing by apt 
# clang is necessary for building on ubuntu
DEP_ARRAY=(wget make cmake git llvm-6.0 clang-6.0 clang++-6.0 build-essential)
#git llvm-4.0 clang-4.0 libclang-4.0-dev make cmake  build-essential curl

ARM_DOWLOAD_URL="http://releases.linaro.org/components/toolchain/binaries/5.5-2017.10/arm-linux-gnueabihf/gcc-linaro-5.5.0-2017.10-x86_64_arm-linux-gnueabihf.tar.xz"
ARM64_DOWLOAD_URL="http://releases.linaro.org/components/toolchain/binaries/5.5-2017.10/aarch64-linux-gnu/gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu.tar.xz"

# 以下交叉编译工具可以 apt 方式安装
# 暂时不安装
CROSS_DEP=(g++-5-mips-linux-gnu g++-5-mips64-linux-gnuabi64 g++-5-powerpc-linux-gnu g++-5-powerpc64-linux-gnu g++-5-arm-linux-gnueabihf g++-5-aarch64-linux-gnu)

# 而 arm-linux-gnueabihf 和 arm64-linux-gnueabi 需要下载安装包
# 下载地址 
# arm-linux-gnueabihf-gcc   http://releases.linaro.org/components/toolchain/binaries/5.5-2017.10/arm-linux-gnueabihf/gcc-linaro-5.5.0-2017.10-x86_64_arm-linux-gnueabihf.tar.xz
# aarch64-linux-gnu-gcc   http://releases.linaro.org/components/toolchain/binaries/5.5-2017.10/aarch64-linux-gnu/gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu.tar.xz

COUNT=1
DISPLAY=""
DEP=""



# add source 

#echo  "deb http://apt.llvm.org/xenial/llvm-toolchain-xenial-6.0 main" >> 

# apt-add-repository 'deb http://us.archive.ubuntu.com/ubuntu/ xenial main restricted universe multiverse' && \
# apt-add-repository 'deb http://us.archive.ubuntu.com/ubuntu/ xenial-updates main restricted universe multiverse' && \
# apt-add-repository 'deb http://us.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse' && \
# apt-add-repository 'deb http://security.ubuntu.com/ubuntu xenial-security main restricted universe multiverse'

wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - 
apt-get update
apt-add-repository "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-6.0 main"

# aliyun 
# if [ $ANSWER != 1 ]; then read -p "if you want to use aliyun sources? (y/n) " ANSWER; fi
# case $ANSWER in
# 	1 | [Yy]* )
# 		echo  "#deb cdrom:[Ubuntu 16.04 LTS _Xenial Xerus_ - Release amd64 (20160420.1)]/ xenial main restricted
# 				deb-src http://archive.ubuntu.com/ubuntu xenial main restricted #Added by software-properties
# 				deb http://mirrors.aliyun.com/ubuntu/ xenial main restricted
# 				deb-src http://mirrors.aliyun.com/ubuntu/ xenial main restricted multiverse universe #Added by software-properties
# 				deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted
# 				deb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted multiverse universe #Added by software-properties
# 				deb http://mirrors.aliyun.com/ubuntu/ xenial universe
# 				deb http://mirrors.aliyun.com/ubuntu/ xenial-updates universe
# 				deb http://mirrors.aliyun.com/ubuntu/ xenial multiverse
# 				deb http://mirrors.aliyun.com/ubuntu/ xenial-updates multiverse
# 				deb http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse
# 				deb-src http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse #Added by software-properties
# 				deb http://archive.canonical.com/ubuntu xenial partner
# 				deb-src http://archive.canonical.com/ubuntu xenial partner
# 				deb http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted
# 				deb-src http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted multiverse universe #Added by software-properties
# 				deb http://mirrors.aliyun.com/ubuntu/ xenial-security universe
# 				deb http://mirrors.aliyun.com/ubuntu/ xenial-security multiverse" > /etc/apt/sources.list;;
# 	[Nn]* ) echo "use default soueces!";;
# 	* ) echo "Please type 'y' for yes or 'n' for no."; exit;;
# esac




if [ $ANSWER != 1 ]; then read -p "Do you wish to update repositories with apt-get update? (y/n) " ANSWER; fi
case $ANSWER in
	1 | [Yy]* )
		if ! apt-get update; then
#		if ! true; then
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
printf ${DEP}
if [ "${COUNT}" -gt 1 ]; then
	printf "\\nThe following dependencies are required to install fibjs:\\n"
	printf "${DISPLAY}\\n\\n" 
	if [ $ANSWER != 1 ]; then read -p "Do you wish to install these packages? (y/n) " ANSWER; fi
	case $ANSWER in
		1 | [Yy]* )
			if ! apt-get -y install ${DEP}; then
#			if ! true; then
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
#			if ! true; then
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
# # install cross compile toolchains
# printf " download and isntall gcc-arm-linux-gnueabihf and aarch64-linux-gnu \n\n"

# # install cross compile toolchains
# printf " download and isntall gcc-arm-linux-gnueabihf and aarch64-linux-gnu \n\n"

# printf "\\nThe following oprations are installing toolchain by binaries if you are trying to crossing-compile:\\n"
# if [ $ANSWER != 1 ]; then read -p "Do you wish to install  packages by binary? (y/n) " ANSWER; fi
# case $ANSWER in
# 	1 | [Yy]* )	
# 	 	#wget -P /usr -O arm-linux-gnueabihf.tar.xz  ${ARM_DOWLOAD_URL} && \
# 	 	mv gcc-linaro-5.5.0-2017.10-x86_64_arm-linux-gnueabihf.tar.xz gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu.tar.xz  /usr/ && \
# 	 	cd /usr && \
# 		tar -Jvxf gcc-linaro-5.5.0-2017.10-x86_64_arm-linux-gnueabihf.tar.xz && \
# 		mv gcc-linaro-5.5.0-2017.10-x86_64_arm-linux-gnueabihf arm-linux-gnueabihf && \
# 		ln -s /usr/arm-linux-gnueabihf/lib/gcc/arm-linux-gnueabihf/5.5.0/crtbegin.o /usr/arm-linux-gnueabihf/arm-linux-gnueabihf/libc/usr/lib/crtbegin.o && \
# 		ln -s /usr/arm-linux-gnueabihf/lib/gcc/arm-linux-gnueabihf/5.5.0/crtend.o /usr/arm-linux-gnueabihf/arm-linux-gnueabihf/libc/usr/lib/crtend.o && \
# 		#wget -P /usr -O aarch64-linux-gnu.tar.xz ${ARM64_DOWLOAD_URL} && \
# 		tar -Jvxf gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu.tar.xz  && \
# 		mv gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu aarch64-linux-gnu && \
# 		ln -s /usr/aarch64-linux-gnu/lib/gcc/aarch64-linux-gnu/5.5.0/crtbegin.o /usr/aarch64-linux-gnu/aarch64-linux-gnu/libc/usr/lib/crtbegin.o && \
# 		ln -s /usr/aarch64-linux-gnu/lib/gcc/aarch64-linux-gnu/5.5.0/crtend.o /usr/aarch64-linux-gnu/aarch64-linux-gnu/libc/usr/lib/crtend.o && \
# 		rm /usr/gcc-linaro-5.5.0-2017.10-x86_64_arm-linux-gnueabihf.tar.xz /usr/gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu.tar.xz  && \
# 		echo "PATH=${PATH}:/usr/arm-linux-gnueabihf/bin:/usr/aarch64-linux-gnu/bin" >> ~/.bashrc  && \
# 		source ~/.bashrc ;;
# 	[Nn]* ) echo "User aborting installation of required dependencies, Exiting now."; exit;;
# 	* ) echo "Please type 'y' for yes or 'n' for no."; exit;;
# esac

#rm /build/gcc-linaro-5.5.0-2017.10-x86_64_arm-linux-gnueabihf.tar.xz /build/gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu.tar.xz 
