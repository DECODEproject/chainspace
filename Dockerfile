# This Dockerfile creates an image based on Decode OS: https://hub.docker.com/r/dyne/decodeos
# With Chainspace installed: https://github.com/DECODEproject/chainspace
#
# Save this into a file named "Dockerfile"
#
# build with:
# docker build . -t  dyne/decodeos:latest
#
# run with:
# docker run -it -p 9001:9001 -p 8081:8081 -p 19999:19999 dyne/decodeos:latest
#
#Then connect to the web interfaces to monitor the functioning of DECODE OS:
#- http://localhost:9001 to supervise the daemons running and their logs
#- http://localhost:8081 to access the values stored
#- http://localhost:19999 to monitor the resource usage


FROM dyne/zenroom:latest
FROM dyne/decodeos:latest
FROM python:2

RUN apt-get update && \
	apt-get install -y openjdk-8-jdk && \

	apt-get install -y virtualenv tree python python-setuptools wget gzip nano \
                           build-essential libssl1.0-dev libffi-dev python-dev && \

	apt-get clean && \
	rm -rf /var/lib/apt/lists/*;

COPY --from=0 /code/zenroom/src/zenroom-static /usr/bin/zenroom
COPY --from=0 /code/zenroom/examples/elgamal  /opt/contracts/

RUN sed -i 's/^NAME.*/NAME="DECODE OS"/' /etc/os-release
RUN sed -i 's/^PRETTY_NAME.*/PRETTY_NAME="DECODE OS: github.com\/DECODEproject\/decode-os"/' /etc/os-release

RUN easy_install pip

WORKDIR /app

RUN virtualenv .chainspace.env
RUN . .chainspace.env/bin/activate && pip install -U setuptools
RUN . .chainspace.env/bin/activate && pip install petlib numpy bplib coconut-lib

RUN wget -q https://sdk.dyne.org:4443/job/chainspace-jar/lastSuccessfulBuild/artifact/target/chainspace-bin-vSNAPSHOT.tgz


WORKDIR /app/chainspace

RUN tar xfz /app/chainspace-bin-vSNAPSHOT.tgz

WORKDIR /app

RUN . .chainspace.env/bin/activate && pip install -e chainspace/lib/chainspaceapi
RUN . .chainspace.env/bin/activate && pip install -e chainspace/lib/chainspacecontract
