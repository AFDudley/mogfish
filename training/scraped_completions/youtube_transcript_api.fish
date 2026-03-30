complete -c youtube_transcript_api -s h -l help -d 'show this help message and exit'
complete -c youtube_transcript_api -l list-transcripts -d 'This will list the languages in which the given videos'
complete -c youtube_transcript_api -l languages -d '[LANGUAGES ...]'
complete -c youtube_transcript_api -l exclude-generated -d 'If this flag is set transcripts which have been'
complete -c youtube_transcript_api -l format -d '{json,pretty,text,webvtt,srt}'
complete -c youtube_transcript_api -l translate -d TRANSLATE
complete -c youtube_transcript_api -l webshare-proxy-username -d WEBSHARE_PROXY_USERNAME
complete -c youtube_transcript_api -l webshare-proxy-password -d WEBSHARE_PROXY_PASSWORD
complete -c youtube_transcript_api -l http-proxy -d 'URL      Use the specified HTTP proxy.'
complete -c youtube_transcript_api -l https-proxy -d 'URL     Use the specified HTTPS proxy.'
complete -c youtube_transcript_api -l cookies -d 'COOKIES     The cookie file that will be used for authorization'
