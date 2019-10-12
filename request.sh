port=$1
url=$2
method='GET'
if [[ -n "$3" ]]; then
    method=$3
fi
header=$4
data=$5
url="http://localhost:$port/$url"
response="$(time curl -X "$method" -H "$header" -d "$data" -v "$url")"
