#!/bin/sh
#说明
show_usage="args: -h,--host= : 数据库主机名\n
                  -u,--user= : 用户名\n 
                  -p,--password= : 密码\n
                  -c,--concurrency= : 并发数\n
                  -n,--auto_generate_sql_execute_number= : 每个并发执行数\n
                  -t,--create_schema= : 数据库名\n
                  -q,--query= : 执行的sql语句\n
	          -z,--count= : 循环的次数"

if [ $# -ne 8 ];then
  /bin/echo -e  $show_usage
fi
#参数
# 数据库主机名
host=""

# 用户名
user=""

# 密码
password=""

# 并发数
concurrency=""

# 每个并发执行数
auto_generate_sql_execute_number=""

# 数据库名
create_schema=""

# 执行的sql语句
query=""

# mysqlslap执行的次数
count=""

GETOPT_ARGS=`getopt -o h:u:p:c:n:t:q:z -al host:,user:,password:,concurrency:,auto_generate_sql_execute_number:,create_schema:,query:,count: -- "$@"`

echo "\n"
echo $GETOPT_ARGS
eval set -- "$GETOPT_ARGS"
#echo $GETOPT_ARGS
#获取参数 shift 2即删除前两个参数
while [ -n "$1" ]
do
        case "$1" in
                -h|--host) host=$2; shift 2;;
                -u|--user) user=$2; shift 2;;
                -p|--password) password=$2; shift 2;;
                -c|--concurrency) concurrency=$2; shift 2;;
	        -n|--auto_generate_sql_execute_number) auto_generate_sql_execute_number=$2; shift 2;;
	        -t|--create_schema) create_schema=$2; shift 2;;
		-q|--query) query=$2; shift 2;;
		-z|--count) count=$2; shift 2;;
                --) break ;;
                *)  /bin/echo -e $1,$2,$show_usage; break ;;
        esac
done
# -z判断字符串是否为空 空1 非空0
if [[ -z $host || -z $user || -z $password || -z $concurrency || -z $auto_generate_sql_execute_number || -z $create_schema || -z $query || -z $count ]]; then
        /bin/echo -e $show_usage
        echo "host: $host , user: $user , password: $password , concurrency: $concurrency, auto_generate_sql_execute_number: $auto_generate_sql_execute_number, create_schema: $create_schema, query: $query, count: $count"
        exit 0
fi

for i in $(seq 1 $count)
do
  mysqlslap --host=$host --user=$user --password=$password --concurrency=$concurrency --auto-generate-sql-execute-number=$auto_generate_sql_execute_number  --create-schema=$create_schema --query="$query"
done
