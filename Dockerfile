FROM openjdk:8-slim

RUN apt update && apt -y install git rsync zip libc++-dev
RUN git clone https://github.com/Lanchon/haystack --depth 1
RUN git clone https://github.com/aureljared/simple-deodexer --depth 1

ADD *.sh ./

CMD ["bash", "./run.sh"]
