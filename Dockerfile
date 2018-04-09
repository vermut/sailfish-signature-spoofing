FROM openjdk

RUN apt update && apt -y install git rsync zip libc++-dev
RUN git clone https://github.com/Lanchon/haystack
RUN git clone https://github.com/aureljared/simple-deodexer

ADD *.sh ./

ENV SAILFISH 172.28.172.1
CMD ["bash", "./run.sh"]
