# install toolchains
if [ $1 == 1 ]; then ANSWER=1; else ANSWER=0; fi
ARM_DOWLOAD_URL="http://releases.linaro.org/components/toolchain/binaries/5.5-2017.10/arm-linux-gnueabihf/gcc-linaro-5.5.0-2017.10-x86_64_arm-linux-gnueabihf.tar.xz"
ARM64_DOWLOAD_URL="http://releases.linaro.org/components/toolchain/binaries/5.5-2017.10/aarch64-linux-gnu/gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu.tar.xz"

# 以下交叉编译工具可以 apt 方式安装
# 暂时不安装
CROSS_DEP=(g++-5-mips-linux-gnu g++-5-mips64-linux-gnuabi64 g++-5-powerpc-linux-gnu g++-5-powerpc64-linux-gnu)


# install cross compile toolchains
printf " download and isntall gcc-arm-linux-gnueabihf and aarch64-linux-gnu \n\n"

printf "\\nThe following oprations are installing toolchain by binaries if you are trying to crossing-compile:\\n"
if [ $ANSWER != 1 ]; then read -p "Do you wish to install  packages by binary? (y/n) " ANSWER; fi
	case $ANSWER in
		1 | [Yy]* )	
		 	#wget -P /usr -O arm-linux-gnueabihf.tar.xz  ${ARM_DOWLOAD_URL} && \
		 	cp gcc-linaro-5.4.1-2017.01-x86_64_arm-linux-gnueabihf.tar.xz gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu.tar.xz  /usr && \
		 	cd /usr && \
			tar -Jvxf gcc-linaro-5.4.1-2017.01-x86_64_arm-linux-gnueabihf.tar.xz && \
			mv gcc-linaro-5.4.1-2017.01-x86_64_arm-linux-gnueabihf arm-linux-gnueabihf && \
			ln -s /usr/arm-linux-gnueabihf/lib/gcc/arm-linux-gnueabihf/5.4.1/crtbegin.o /usr/arm-linux-gnueabihf/arm-linux-gnueabihf/libc/usr/lib/crtbegin.o && \
			ln -s /usr/arm-linux-gnueabihf/lib/gcc/arm-linux-gnueabihf/5.4.1/crtend.o /usr/arm-linux-gnueabihf/arm-linux-gnueabihf/libc/usr/lib/crtend.o && \
		 	rm ./gcc-linaro-5.4.1-2017.01-x86_64_arm-linux-gnueabihf.tar.xz && \
			#wget -P /usr -O aarch64-linux-gnu.tar.xz ${ARM64_DOWLOAD_URL} && \
			tar -Jvxf gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu.tar.xz  && \
			mv gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu aarch64-linux-gnu && \
			ln -s /usr/aarch64-linux-gnu/lib/gcc/aarch64-linux-gnu/5.5.0/crtbegin.o /usr/aarch64-linux-gnu/aarch64-linux-gnu/libc/usr/lib/crtbegin.o && \
			ln -s /usr/aarch64-linux-gnu/lib/gcc/aarch64-linux-gnu/5.5.0/crtend.o /usr/aarch64-linux-gnu/aarch64-linux-gnu/libc/usr/lib/crtend.o && \
			rm ./gcc-linaro-5.5.0-2017.10-x86_64_aarch64-linux-gnu.tar.xz && \
			echo "PATH=${PATH}:/usr/arm-linux-gnueabihf/bin:/usr/aarch64-linux-gnu/bin" >> ~/.bashrc  && \
			source ~/.bashrc ;;
		[Nn]* ) echo "User aborting installation of required dependencies, Exiting now."; exit;;
		* ) echo "Please type 'y' for yes or 'n' for no."; exit;;
	esac

cd /work