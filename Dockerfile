FROM tiangolo/uwsgi-nginx-flask:python3.6

RUN mkdir /code
WORKDIR /code
ADD requirements.txt /code/
RUN pip install -r requirements.txt --no-cache-dir
ADD . /code/

# ssh
ENV SSH_PASSWD "root:Docker!"
RUN apt-get update \
        && apt-get install -y --no-install-recommends dialog \
        && apt-get update \
	&& apt-get install -y --no-install-recommends openssh-server \
	&& echo "$SSH_PASSWD" | chpasswd 

COPY sshd_config /etc/ssh/
COPY init.sh /usr/local/bin/
	
RUN chmod u+x /usr/local/bin/init.sh
EXPOSE 8000 2222
#CMD ["python", "/code/manage.py", "runserver", "0.0.0.0:8000"]
ENTRYPOINT ["init.sh"]

# Twistlock Container Defender - app embedded
ADD twistlock_defender_app_embedded.tar.gz ./tmp
ENV DEFENDER_TYPE="appEmbedded"
ENV DEFENDER_APP_ID="gcp-webapp"
ENV FILESYSTEM_MONITORING="false"
ENV WS_ADDRESS="wss://app0.cloud.twistlock.com:443"
ENV DATA_FOLDER="./tmp"
ENV INSTALL_BUNDLE="eyJzZWNyZXRzIjp7InNlcnZpY2UtcGFyYW1ldGVyIjoibXVDR2kvS1I5bW9LWGc5RDVrclFkTjUvcEdlWjZiQldiQmhUajNXZzFvZUw2ZzM5d0txaWpQNW9nNDAzczFpVUJMbU8wWlZDVmdhSVFCTEVwMVk3UWc9PSJ9LCJnbG9iYWxQcm94eU9wdCI6eyJodHRwUHJveHkiOiIiLCJub1Byb3h5IjoiIiwiY2EiOiIiLCJ1c2VyIjoiIiwicGFzc3dvcmQiOnsiZW5jcnlwdGVkIjoiIn19LCJjdXN0b21lcklEIjoiYXBwMC05MzA4Mjc2NCIsImFwaUtleSI6IkRERUMxL1lTWFlsc2ZyaGRjTHhCODVzeVpjdGlJalRkRmltd2tUMjJmS01acTJ3aFNERVkrWWxUc0RRM3VId0RMRFhvcUhjVHpDVERxU2d3Tk1sSlp3PT0iLCJtaWNyb3NlZ0NvbXBhdGlibGUiOmZhbHNlLCJpbWFnZVNjYW5JRCI6IjUzNThhMTc5LTdmYTEtOWVkZi0yYjFjLTlkYTc3NzU2ZWNiOCJ9"
ENV FIPS_ENABLED="false"
ENTRYPOINT ["tmp/defender", "app-embedded", "init.sh"]