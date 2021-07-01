#!/bin/bash

name=app-deploy
log_file=$name.$(date +%Y%m%d_%H%M%S).log
exec 3>&1 1>>$log_file 2>&1

function log_info {
    printf "\e[1;34m$(date '+%Y-%m-%d %T') %s\e[0m\n" "$@" 1>&3
}

function log_success {
    printf "\e[1;32m$(date '+%Y-%m-%d %T') %s\e[0m\n" "$@" 1>&3
}

function log_warning {
    printf "\e[1;33m$(date '+%Y-%m-%d %T') %s\e[0m\n" "$@" 1>&3
}

function log_error {
    printf >&2 "\e[1;31m$(date '+%Y-%m-%d %T') %s\e[0m\n" "$@" 1>&3
}

function installApp {
        cd /

        log_info "Running git clone ${app_url}."
        git clone ${app_url}
        [ $? -ne 0 ] && log_error "Error during git clone operation." && return 1

        cd /${app_repo}

        log_info "Running apt-get update."
        export DEBIAN_FRONTEND=noninteractive
        apt update
        [ $? -ne 0 ] && log_error "apt-get update command execution error." && return 1

        log_info "Running apt-get install nginx php."
        apt install php-fpm nginx -y
        [ $? -ne 0 ] && log_error "apt-get install command execution error." && return 1

        log_info "Copying files to /var/www/html."
        cd /${app_repo}/${app_directory}
        cp -a * /var/www/html/
        [ $? -ne 0 ] && log_error "copy files failed." && return 1

        log_info "Starting nginx service."
        service nginx start

    return 0
}

function configureApp {
  phpversion=$(ls /etc/php/)

cat > "/etc/nginx/sites-available/default" <<- EOF
server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/html;

        index index.php index.html index.htm index.nginx-debian.html;

        server_name _ ${lb_hostname_public};

        location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                # try_files \$uri \$uri/ =404;
                try_files \$uri \$uri/ \$uri.html \$uri.php\$is_args\$query_string;
        }

        location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/var/run/php/php$${phpversion}-fpm.sock;
                fastcgi_param LB_INTERNAL ${lb_hostname_private};
        }
}
EOF
  
  current_time=$(date "+%Y.%m.%d-%H.%M.%S.%N")
  echo "Current Time : $$current_time"

  echo "I'm a new server created on $${current_time}" > /var/www/html/server.html

  service nginx restart

  return 0
}

function first_boot_setup {
    log_info "Started $name server configuration from cloud-init."

    systemctl stop apt-daily.service
    systemctl kill --kill-who=all apt-daily.service

    log_info "Checking apt lock status"
    is_apt_running=$(ps aux | grep -i apt | grep lock_is_held | wc -l)
    until [ "$is_apt_running" = 0 ]; do
        log_warning "Sleeping for 5 seconds while apt lock_is_held."
        sleep 5
        
        log_info "Checking apt lock status"
        is_apt_running=$(ps aux | grep -i apt | grep lock_is_held | wc -l)
    done

    installApp
    [ $? -ne 0 ] && log_error "Failed app installation, review log file $log_file." && return 1

    configureApp
    [ $? -ne 0 ] && log_error "Failed app installation, review log file $log_file." && return 1

    return 0
}

first_boot_setup
[ $? -ne 0 ] && log_error "app-deploy had errors." && exit 1

exit 0