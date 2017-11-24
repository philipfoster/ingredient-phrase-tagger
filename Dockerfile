FROM ubuntu:16.04
MAINTAINER recipebook.dev@gmail.com
VOLUME /tmp
EXPOSE 5000

# 1m max file uploads
ENV NGINX_MAX_UPLOAD 1m
ENV STATIC_INDEX 0
ENV USER_NAME taggerapp
ENV APP_HOME /home/$USER_NAME/app
ENV CRFPP_DIR $APP_HOME/lib/CRFPP-0.58

# update packages and install python
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y python python-pip python-dev build-essential


RUN useradd -ms /bin/bash $USER_NAME
RUN mkdir $APP_HOME

RUN pip2 install --upgrade pip


COPY . $APP_HOME
WORKDIR $APP_HOME
RUN chown $USER_NAME $APP_HOME/


# install crf++ dependency
RUN $CRFPP_DIR/configure
RUN make $CRFPP_DIR
RUN make install $CRFPP_DIR
ENV LD_LIBRARY_PATH /usr/local/lib

# install python dependencies
RUN pip2 install --trusted-host pypi.python.org -r $APP_HOME/requirements.txt

# Start the server
ENTRYPOINT ["python"]
CMD ["server.py"]
