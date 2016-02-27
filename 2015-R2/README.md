# docker-openemm
OpenEMM System dockerized!

### Installation

Pull image:

	docker pull bulktrade/openemm
	
### Usage with docker-compose

	openemm:
        image: bulktrade/openemm
        restart: always
        ports:
            - 8080
        links:
            - mysql:MYSQL
            - mail:MAIL
        environment:
            - OPEN_EMM_URL=http://openemm.local
            - OPEN_EMM_HOSTNAME=openemm.local
            - VIRTUAL_HOST=~^openemm\..* # for rproxy (jwilder/nginx-proxy)
            - CERT_NAME=default
            - VIRTUAL_PORT=8080
            - MAIL_ADDRESSES=newsletter info # For bounce management 
    #        - 'MAIL_HOST=mx.local' # uncomment if you are using remote smtp server
    #        - 'MAIL_USERNAME_AND_PASSWORD=username:password' # uncomment if you are using a remote smtp server
    
    ocron:
        image: bulktrade/openemm
        links:
            - mysql:MYSQL
            - mail:MAIL
        command: /start-cron.sh
        restart: always
    
    mail:
      image: catatnight/postfix
      restart: always
      ports:
          - 25
      environment:
        smtp_user: "openemm:1234567fsdfsg"
        maildomain: "mx.local"
    
    mysql:
        restart: always
        image: tutum/mysql
        environment:
           - MYSQL_PASS=openemm1241343
           
[On DockerHub](https://registry.hub.docker.com/u/bulktrade/openemm/)
