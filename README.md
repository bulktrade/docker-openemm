# docker-openemm
OpenEMM System dockerized!

### Installation

Pull image:

	docker pull bulktrade/openemm
	
### Usage with docker-compose

	openemm:
        image: bulktrade/openemm
        ports:
            - 8080
        links:
            - mysql:MYSQL
            - mail:MAIL
        volumes_from:
            - mail
            - mysql
        environment:
            - OPEN_EMM_URL=http://openemm.local
            - OPEN_EMM_HOSTNAME=openemm.local
            - VIRTUAL_HOST=~^openemm\..* # for rproxy (jwilder/nginx-proxy)
            - CERT_NAME=default
            - VIRTUAL_PORT=8080
    
    mail:
      image: catatnight/postfix
      ports:
          - 25
      environment:
        smtp_user: "openemm:1234567fsdfsg"
        maildomain: "mx.local"
    
    mysql:
        image: tutum/mysql
        environment:
           - MYSQL_PASS=openemm1241343