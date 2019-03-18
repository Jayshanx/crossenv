FROM ubuntu:14.04

MAINTAINER ngot "https://github.com/ngot"

RUN apt-get update
RUN apt-get install software-properties-common -y
RUN add-apt-repository 'deb http://us.archive.ubuntu.com/ubuntu/ xenial main restricted universe multiverse' && \
add-apt-repository 'deb http://us.archive.ubuntu.com/ubuntu/ xenial-updates main restricted universe multiverse' && \
add-apt-repository 'deb http://us.archive.ubuntu.com/ubuntu/ xenial-backports main restricted universe multiverse' && \
add-apt-repository 'deb http://security.ubuntu.com/ubuntu xenial-security main restricted universe multiverse'

RUN apt-get update
RUN apt-get install curl g++ make cmake git g++-multilib -y
RUN rm -f /usr/include/asm
RUN ln -s x86_64-linux-gnu /usr/include/i386-linux-gnu
RUN ln -s x86_64-linux-gnu /usr/include/x86_64-linux-gnux32

RUN apt-get install g++-5-arm-linux-gnueabihf -y
RUN rm -f /usr/bin/arm-linux-gnueabihf-gcc
RUN rm -f /usr/bin/arm-linux-gnueabihf-g++
RUN ln -s arm-linux-gnueabihf-gcc-5 /usr/bin/arm-linux-gnueabihf-gcc
RUN ln -s arm-linux-gnueabihf-g++-5 /usr/bin/arm-linux-gnueabihf-g++

RUN apt-get install g++-5-aarch64-linux-gnu -y
RUN rm -f /usr/bin/aarch64-linux-gnu-gcc
RUN rm -f /usr/bin/aarch64-linux-gnu-g++
RUN ln -s aarch64-linux-gnu-gcc-5 /usr/bin/aarch64-linux-gnu-gcc
RUN ln -s aarch64-linux-gnu-g++-5 /usr/bin/aarch64-linux-gnu-g++

RUN apt-get install g++-5-mips-linux-gnu -y
RUN rm -f /usr/bin/mips-linux-gnu-gcc
RUN rm -f /usr/bin/mips-linux-gnu-g++
RUN ln -s mips-linux-gnu-gcc-5 /usr/bin/mips-linux-gnu-gcc
RUN ln -s mips-linux-gnu-g++-5 /usr/bin/mips-linux-gnu-g++

RUN apt-get install g++-5-mips64-linux-gnuabi64 -y
RUN rm -f /usr/bin/mips64-linux-gnuabi64-gcc
RUN rm -f /usr/bin/mips64-linux-gnuabi64-g++
RUN ln -s mips64-linux-gnuabi64-gcc-5 /usr/bin/mips64-linux-gnuabi64-gcc
RUN ln -s mips64-linux-gnuabi64-g++-5 /usr/bin/mips64-linux-gnuabi64-g++

RUN apt-get install g++-5-arm-linux-gnueabihf -y
RUN rm -f /usr/bin/arm-linux-gnueabihf-gcc
RUN rm -f /usr/bin/arm-linux-gnueabihf-g++
RUN ln -s arm-linux-gnueabihf-gcc-5 /usr/bin/arm-linux-gnueabihf-gcc
RUN ln -s arm-linux-gnueabihf-g++-5 /usr/bin/arm-linux-gnueabihf-g++
