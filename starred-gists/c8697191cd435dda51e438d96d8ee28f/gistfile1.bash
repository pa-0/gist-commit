urlencode() {
    # urlencode <string>
    local LC_ALL=C c i n
    for (( i = 0, n = ${#1}; i < n; i++ )); do
        c=${1:i:1}
        case $c in
            [[:alnum:].~_-]) printf %s "$c" ;;
            *) printf %%%02X "'$c"  ;;
        esac
    done
}

urldecode() {
    # urldecode <string>
    local s
    s=${1//\\/\\\\}
    s=${s//+/ }
    printf %b "${s//'%'/\\x}"
}
