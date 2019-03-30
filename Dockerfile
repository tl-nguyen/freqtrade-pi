FROM python:3.7.2-slim-stretch

RUN apt-get update \
 && apt-get -y install wget curl build-essential libssl-dev libffi-dev \
 && apt-get clean

# Prepare environment
RUN mkdir /freqtrade
WORKDIR /freqtrade

# Install TA-lib
COPY build_helpers/ta-lib-0.4.0-src.tar.gz /freqtrade/
RUN tar -xzf /freqtrade/ta-lib-0.4.0-src.tar.gz \
 && cd /freqtrade/ta-lib/ \
 && ./configure \
 && make \
 && make install \
 && rm /freqtrade/ta-lib-0.4.0-src.tar.gz

ENV LD_LIBRARY_PATH /usr/local/lib

# Install berryconda
RUN wget https://github.com/jjhelmus/berryconda/releases/download/v2.0.0/Berryconda3-2.0.0-Linux-armv7l.sh \
 && bash ./Berryconda3-2.0.0-Linux-armv7l.sh -b \
 && rm Berryconda3-2.0.0-Linux-armv7l.sh

# Install dependencies
COPY requirements.txt /freqtrade/
RUN ~/berryconda3/bin/conda install -y numpy pandas scipy \
 && ~/berryconda3/bin/pip install -r requirements.txt --no-cache-dir

# Install and execute
COPY . /freqtrade/
RUN ~/berryconda3/bin/pip install -e . --no-cache-dir

ENTRYPOINT ["/root/berryconda3/bin/python","./freqtrade/main.py"]