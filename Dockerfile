FROM awesomeserver:current

MAINTAINER Tadas Ustinavičius <tadas.ustinavicius@ittc.vu.lt>


EXPOSE 80
ENTRYPOINT /usr/sbin/apache2ctl -D FOREGROUND