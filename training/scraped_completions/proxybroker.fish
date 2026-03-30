complete -c proxybroker -l max-conn -d 'MAX_CONN   The maximum number of concurrent checks of proxies'
complete -c proxybroker -l max-tries -d MAX_TRIES
complete -c proxybroker -l timeout -d 'SECONDS, -t SECONDS'
complete -c proxybroker -l judge -d 'JUDGES        Urls of pages that show HTTP headers and IP address'
complete -c proxybroker -l provider -d 'PROVIDERS  Urls of pages where to find proxies'
complete -c proxybroker -l log -d '[{NOTSET,DEBUG,INFO,WARNING,ERROR,CRITICAL}]'
complete -c proxybroker -n __fish_no_arguments -s v -l version -d Show\ program\'s\ version\ number\ and\ exit
complete -c proxybroker -s h -l help -d 'Show this help message and exit'
