FROM debian:10
ENV FORCE_UNSAFE_CONFIGURE 1
RUN apt update
RUN apt install -y \
	git \
	build-essential \
	bc \
	curl \
	wget \
	file \
	cpio \
	rsync \
	unzip \
	python3 \
	debootstrap \
	qemu-user \
	qemu-user-static \
	nano \
	libpcre3-dev \
	libz-dev \
	automake
