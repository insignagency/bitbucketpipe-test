FROM insignagency/php:php7.3

COPY pipe.sh /
ENTRYPOINT ["/pipe.sh"]