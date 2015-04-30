FROM ubuntu:14.04

MAINTAINER Niels Buus

# Update repositories

RUN apt-get update -y

# Dependencies for PhantomJS
RUN apt-get install -y build-essential g++ flex bison gperf ruby perl \
  libsqlite3-dev libfontconfig1-dev libicu-dev libfreetype6 libssl-dev \
  libpng-dev libjpeg-dev python git-core

# Dependencies for html2pdf
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y nodejs

ENV REFRESHED_AT 1

RUN mkdir html2pdf

COPY . /html2pdf

EXPOSE 8080

WORKDIR /html2pdf

ENTRYPOINT nodejs .
