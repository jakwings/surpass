set -a __fish_surpass_user_commands \
'migrate	Migrate passwords from pass(1) to surpass(1)'

complete -c surpass-migrate -f

## example
#complete -c surpass-migrate -n '__fish_surpass_seen_nothing' \
#                            -a start -d 'Start migration'
