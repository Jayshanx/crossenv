#!/bin/bash
CROSS_DEP=(
	g++-5-mips-linux-gnu g++-5-mips64-linux-gnuabi64 g++-5-powerpc-linux-gnu g++-5-powerpc64-linux-gnu g++-5-arm-linux-gnueabihf g++-5-aarch64-linux-gnu
)
DEP_ARRAY=(wget make cmake git llvm-6.0 clang-6.0 clang++-6.0 build-essential)
DEP=""

# install toolchains
printf "\\nThe following are toolchain packages if you are trying to crossing-compile:\\n"
for (( i=0; i<${#CROSS_DEP[@]}; i++ )); do
	printf " - ${CROSS_DEP[$i]} \n "
	DEP=$DEP" ${CROSS_DEP[$i]} "
done

sudo apt-get install -y ${DEP}


sudo docker run -it -v /home/xiao/fibjs:/ci crossenv:2 /bin/bash -c "cd /ci && sh build release arm"
