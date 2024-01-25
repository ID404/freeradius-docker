FROM ubuntu:jammy

# china timezone
RUN echo "Asia/Shanghai" > /etc/timezone

RUN apt-get update -y \
 && apt-get install -y \
    freeradius \
    libpam-google-authenticator \
 && rm -rf /var/lib/apt/lists/* 


RUN sed -i "s/^@\(.*\)/#@\1/g" /etc/pam.d/radiusd
RUN echo "auth requisite pam_google_authenticator.so forward_pass" >> /etc/pam.d/radiusd
RUN echo "auth required pam_unix.so use_first_pass" >> /etc/pam.d/radiusd

RUN sed -i "s/^#\(.*pam\)/\1/g" /etc/freeradius/3.0/sites-available/default
RUN echo "DEFAULT Auth-Type := PAM" >> /etc/freeradius/3.0/users
RUN echo "\n\nclient 0.0.0.0/0 {\n\tsecret = %RADIUS_SECRET%\n\tshortname = freeradius\n}\n" >> /etc/freeradius/3.0/clients.conf
RUN sed -i "s/^\([user|group].*\=.*\)freerad/\1root/g" /etc/freeradius/3.0/radiusd.conf

RUN ln -s /etc/freeradius/3.0/mods-available/pam /etc/freeradius/3.0/mods-enabled/



ADD ./config /root/
RUN mv -f /root/radiusd.conf /etc/freeradius/3.0/ \
 && mv -f /root/users /etc/freeradius/3.0/ \
 && mv -f /root/default /etc/freeradius/3.0/sites-enabled/ \
 && mv -f /root/radiusd /etc/pam.d/ \
 && mv -f /root/clients.conf /etc/freeradius/3.0/

EXPOSE 1812/udp
EXPOSE 1813/udp
EXPOSE 1814/udp
EXPOSE 18120/udp

CMD /usr/sbin/freeradius -xx -f -l /dev/stdout
