#!/bin/bash
set -eux

# Path to the mounted data volume
DATADIR = "/var/lib/mysql"

# The environment variables we expect to be set:
#   * MYSQL_ROOT_PASSWORD_FILE  (path to a secret file containing the root password)
#   * MYSQL_DATABASE           (database name, e.g. "wordpress")
#   * MYSQL_USER               (e.g. "wp_user")
#   * MYSQL_PASSWORD_FILE      (path to a secret file containing the non-root user password)

# If $DATADIR/mysql does not exist, this is the first time we run:
if [ ! -d "$DATADIR/mysql" ]; then
    echo "[mariadb] First initialization..."
    # Initialize the MariaDB data directory with no root password (we will set it shortly)
    mysqld --initialize-insecure --user=mysql --datadir="$DATADIR"
    echo "[mariadb] Data directory initialized."

    # Start the server in the background, bound to localhost only so remote access is not yet open:
    mysqld --skip-networking --socket=/tmp/mysql.sock --pid-file=/tmp/mysql.pid &
    pid="$!"
    echo "[mariadb] Waiting for mysqld (PID=$pid) to come up..."
    # Wait until we can connect to the socket
    until mysql --protocol=SOCKET --socket=/tmp/mysql.sock -uroot -e "SELECT 1" &> /dev/null; do
      sleep 0.1
    done
    echo "[mariadb] mysqld is running."

    # 1) Set the root password:
    if [ -n "$ROOT_PWD" ]; then
      mysql --protocol=SOCKET --socket=/tmp/mysql.sock -uroot -e \
        "ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PWD}';"
      echo "[mariadb] Root password set."
    else
      echo "[mariadb] WARNING: MYSQL_ROOT_PASSWORD_FILE not set or empty—root will have no password!"
    fi

    # 2) Create the application database:
    if [ -n "$MYSQL_DATABASE" ]; then
      mysql --protocol=SOCKET --socket=/tmp/mysql.sock -uroot -p"${ROOT_PWD}" -e \
        "CREATE DATABASE \`$MYSQL_DATABASE\`;"
      echo "[mariadb] Database '$MYSQL_DATABASE' created."
    fi

    # 3) Create a normal user and grant privileges:
    if [ -n "$MYSQL_USER" ] && [ -n "$USER_PWD" ] && [ -n "$MYSQL_DATABASE" ]; then
      mysql --protocol=SOCKET --socket=/tmp/mysql.sock -uroot -p"${ROOT_PWD}" -e \
        "CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${USER_PWD}';"
      mysql --protocol=SOCKET --socket=/tmp/mysql.sock -uroot -p"${ROOT_PWD}" -e \
        "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';"
      echo "[mariadb] Created user '$MYSQL_USER'@'%', granted privileges on '$MYSQL_DATABASE'."
    fi

    # 4) Flush privileges
    mysql --protocol=SOCKET --socket=/tmp/mysql.sock -uroot -p"${ROOT_PWD}" -e "FLUSH PRIVILEGES;"

    # 5) Cleanly shut down the temporary mysqld
    mysql --protocol=SOCKET --socket=/tmp/mysql.sock -uroot -p"${ROOT_PWD}" -e "SHUTDOWN;"
    wait "$pid"
    echo "[mariadb] Initialization complete; mysqld stopped."
fi

# Finally, exec the real mysqld (so it becomes PID 1; no 'service' or infinite while‐loop hacks).
exec mysqld --user=mysql --datadir="$DATADIR" --bind-address=0.0.0.0