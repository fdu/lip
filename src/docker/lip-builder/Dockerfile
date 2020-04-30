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
	unzip
RUN apt install -y \
	python3
RUN apt install -y \
	debootstrap \
	qemu-user \
	qemu-user-static