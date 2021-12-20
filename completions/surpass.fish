set -l cmds help init new show edit find tree list copy move remove own keys
set -l aliases search ls cp mv rename rm delete del

set __fish_surpass_subcommands "\
help	Show usage of commands or this program
init	Initialize a new key pair
new	Generate a new password
show	Extract the password from a passfile
edit	Update a passfile with input from stdin
find	Search for passfiles in the store
tree	Show a tree-view of passfiles in a folder
list	Show a list of passfiles in a folder
copy	Copy a passfile or folder
move	Move a passfile or folder
remove	Erase a passfile or folder
own	Claim ownership of passfiles
keys	List all available key pairs
"
set __fish_surpass_user_commands  # extended by users

function __fish_surpass_describe
    echo -- $__fish_surpass_subcommands
    if command -q sort
        string join -- \n $__fish_surpass_user_commands | sort -t\t
    else
        string join -- \n $__fish_surpass_user_commands
    end
end

function __fish_surpass_seen_nothing
    test (count (commandline -poc)) -lt 2
end

function __fish_surpass_seen_n_args
    set -l n $argv[1]
    set -l cli (commandline -poc)
    if string match --quiet -- '+*' $n
        test (count $cli) -ge (math 0 + $n + 1)
    else if string match --quiet -- '-*' $n
        test (count $cli) -le (math 0 - $n + 1)
    else
        test (count $cli) -eq (math 0 + $n + 1)
    end
end

function __fish_surpass_seen_n_args_of_cmds
    set -l n $argv[1]
    set -e argv[1]
    set -l cli (commandline -poc)
    if string match --quiet -- '+*' $n
        test (count $cli) -ge (math 0 + $n + 2) && contains -- "$cli[2]" $argv
    else if string match --quiet -- '-*' $n
        test (count $cli) -le (math 0 - $n + 2) && contains -- "$cli[2]" $argv
    else
        test (count $cli) -eq (math 0 + $n + 2) && contains -- "$cli[2]" $argv
    end
end

function __fish_surpass_get_opts
    switch (commandline -pt)
    case 'key=*'
        string join \n key=(surpass keys)
    case '*'
        string join \n $argv
    end
end


## BUILTIN COMMANDS

complete -c surpass -f  # disable file completions

complete -c surpass -n '__fish_surpass_seen_nothing' \
                    -a '(__fish_surpass_describe)' -k

complete -c surpass -n '__fish_surpass_seen_n_args_of_cmds 0 help' \
                    -a "$cmds $aliases"

complete -c surpass -n '__fish_surpass_seen_n_args_of_cmds +0 init' \
                    -a '(__fish_surpass_get_opts key= force)' -k

complete -c surpass -n '__fish_surpass_seen_n_args_of_cmds 0 new' \
                    -a '(surpass list)' -k
complete -c surpass -n '__fish_surpass_seen_n_args_of_cmds +1 new' \
                    -a '(__fish_surpass_get_opts copy push size= charset= grep= key= force)' -k

complete -c surpass -n '__fish_surpass_seen_n_args_of_cmds 0 show' \
                    -a '(surpass list)' -k
complete -c surpass -n '__fish_surpass_seen_n_args_of_cmds +1 show' \
                    -a '(__fish_surpass_get_opts copy line= grep= force)' -k

complete -c surpass -n '__fish_surpass_seen_n_args_of_cmds 0 edit' \
                    -a '(surpass list)' -k
complete -c surpass -n '__fish_surpass_seen_n_args_of_cmds +1 edit' \
                    -a '(__fish_surpass_get_opts copy push show key= force)' -k

complete -c surpass -n '__fish_surpass_seen_n_args_of_cmds 0 find search' \
                    -a '(surpass list)' -k
complete -c surpass -n '__fish_surpass_seen_n_args_of_cmds +1 find search' \
                    -a '(__fish_surpass_get_opts tree)' -k

complete -c surpass -n '__fish_surpass_seen_n_args_of_cmds 0 tree' \
                    -a '(surpass list)' -k

complete -c surpass -n '__fish_surpass_seen_n_args_of_cmds 0 list ls' \
                    -a '(surpass list)' -k

complete -c surpass -n '__fish_surpass_seen_n_args_of_cmds -1 copy cp' \
                    -a '(surpass list)' -k
complete -c surpass -n '__fish_surpass_seen_n_args_of_cmds +2 copy cp' \
                    -a '(__fish_surpass_get_opts force)' -k

complete -c surpass -n '__fish_surpass_seen_n_args_of_cmds -1 move mv rename' \
                    -a '(surpass list)' -k
complete -c surpass -n '__fish_surpass_seen_n_args_of_cmds +2 move mv rename' \
                    -a '(__fish_surpass_get_opts force)' -k

complete -c surpass -n '__fish_surpass_seen_n_args_of_cmds 0 remove rm delete del' \
                    -a '(surpass list)' -k
complete -c surpass -n '__fish_surpass_seen_n_args_of_cmds +1 remove rm delete del' \
                    -a '(__fish_surpass_get_opts all force)' -k

complete -c surpass -n '__fish_surpass_seen_n_args_of_cmds 0 own' \
                    -a '(surpass list)' -k
complete -c surpass -n '__fish_surpass_seen_n_args_of_cmds +1 own' \
                    -a '(__fish_surpass_get_opts key= force)' -k


## USER COMMANDS

function __fish_surpass_seen_user_cmd -V cmds -V aliases
    set -l cli (commandline -poc)
    if set -q cli[2]
        not contains -- "$cli[2]" $cmds $aliases
    else
        set -l cmd (commandline -pt)
        test -n "$cmd" && not contains -- "$cmd" $cmds $aliases
    end
end

function __fish_surpass_complete_user_cmd
    set -l cli (commandline -poc)
    if set -q cli[2]
        set -l cmd $cli[2]
        set -l args $cli[3..] (commandline -pt)
        complete -C "surpass-$cmd "(string join ' ' (string escape -- $args))
    else
        set -l cmd (commandline -pt)
        if test -n "$cmd"
            string replace -r '^surpass-' '' (complete -C "surpass-$cmd")
        end
    end
end

complete -c surpass -n '__fish_surpass_seen_user_cmd' \
                    -a '(__fish_surpass_complete_user_cmd)' -k

set -l paths $PATH/surpass-*
for cmd in (string replace -r '^.*/surpass-([^/]+)$' '$1' $paths)
    complete -C "surpass-$cmd " >/dev/null  # preload comletion scripts
end
