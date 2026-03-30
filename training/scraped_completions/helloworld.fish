# tabでファイル名が補完されるのを無効化する
complete --command=helloworld --no-files

# -h, --help が補完されるようにする
complete --command=helloworld --short=h --long=help --description="Show help message."
