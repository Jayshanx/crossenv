
declare -A CROSS_ARRY_MAP=(["mips"]="g++-5-mips-linux-gnu" ["mips64"]="g++-5-mips64-linux-gnuabi64" ["powerpc"]="g++-5-powerpc-linux-gnu" ["powerpc64"]="g++-5-powerpc64-linux-gnu" ["arm"]="g++-5-arm-linux-gnueabihf" ["aarch64"]="g++-5-aarch64-linux-gnu")
#map=(["100"]="1" ["200"]="2")  
DEP_ARRAY=(make cmake git clang-6.0 xz-utils)

DEP_ARRAYS="${DEP_ARRAY[@]} ${CROSS_ARRY_MAP["$1"]}"

CROSS_COMPILE=${CROSS_ARRY_MAP["$1"]}
if [ -n "$CROSS_COMPILE" ];then
	printf "$CROSS_COMPILE \n"
fi

echo ${DEP_ARRAYS[@]}

clang=0

in=$(echo ${DEP_ARRAY[@]} | grep -wq "clang-6.s0" &&  echo "in")
if [ -n "$in" ];then
	printf "aaa"
fi