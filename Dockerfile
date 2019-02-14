FROM openjdk

RUN apt update && apt -y install git rsync zip libc++-dev squashfs-tools make gcc zlib1g-dev
RUN git clone https://github.com/Lanchon/haystack
RUN git clone https://github.com/aureljared/simple-deodexer
RUN git clone https://github.com/anestisb/vdexExtractor && cd /vdexExtractor && ./make.sh

ADD *.sh ./

ENV SAILFISH 172.28.172.1
CMD ["bash", "./run.sh"]
