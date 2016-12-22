BASE_DIR='/home/ec2-user'
PROJECT='cowlib-server'
COMMAND=$1
SERVER_PID="$BASE_DIR/deploy/$PROJECT.pid"
START_LOG="$BASE_DIR/logs/server-start.log"

start_server() {
    RUN_CMD="java -jar /home/ec2-user/cowlib-server/build/libs/cowlib-server.jar --spring.profiles.active=local"
    echo "Starting $PROJECT ..."

    if running $SERVER_PID ; then
        echo "Already Running $(cat $SERVER_PID)!"
        return 1
    fi

    nohup $RUN_CMD 1> $START_LOG 2>&1 &
    echo $! > "$SERVER_PID"

    if started "$SERVER_PID" ; then
        echo "OK `date`"
    else
        echo "FAILED `date`"
        return 1
    fi
    return 0
}

stop_server() {
    echo "Stopping $PROJECT ..."
    if [ ! -f "$SERVER_PID" ] ; then
        echo "ERROR: no pid found at $SERVER_PID"
        return 1
    fi

    PID=$(cat "$SERVER_PID" 2>/dev/null)
    if [ -z "$PID" ] ; then
        echo "ERROR: no pid id found in $SERVER_PID"
        return 1
    fi
    
    kill "$PID" 2>/dev/null

    TIMEOUT=30
    while running $SERVER_PID ; do
        if (( TIMEOUT-- == 0 )) ; then
            kill -KILL "$PID" 2>/dev/null
        fi
        sleep 1
    done

    if running $SERVER_PID ; then
        echo "FAILED"
        return 1
    else
        rm -f "$SERVER_PID"
        echo "OK"
    fi
}

started() {
    local PID=$(cat "$1" 2>/dev/null) || return 1
    if ps -p $PID > /dev/null ; then
        return 0
    else
        return 1  
    fi
}

running() {
    if [ -f "$1" ] ; then
        local PID=$(cat "$1" 2>/dev/null) || return 1
        if ps -p $PID > /dev/null ; then
            return 0
        fi    
    fi
    return 1
}

if [ $PROJECT == 'cowlib-server' ] ; then
    case $COMMAND in
    start)
        start_server
        ;;
    
    stop)
        stop_server   
        ;;
    
    restart)
        stop_server
        start_server
        ;;
    
    check)
        if running "$SERVER_PID" ; then
            echo "$PROJECT running pid $(< "$SERVER_PID")"
            exit 0
        fi
        exit 1
        ;;
    *)
    ;;
    esac
fi


