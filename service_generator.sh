#!/bin/sh
# init vars
service="$1"
action="$2"
desc="$3"
quiet=$quiet
if [ -z "$desc" ]; then
	desc="$1 service"
fi

# action stop implies quiet mode and check disabling
if [ "$action" = "stop" ]; then
	quiet=1
else
	check=1
fi

# common part
service_body() {
	cat <<-EOF
		if [ -f /var/lock/subsys/$service ]; then
			/sbin/service $service $action 1>&2 || :;
	EOF

	if [ "$quiet" != 1 ]; then
		cat <<-EOF
		else
			echo 'Run "/sbin/service $service start" to start $desc.'
		EOF
	fi
	cat <<-EOF
		fi
	EOF
}

# include check function
skip_auto_restart_body() {
	cat <<-EOF
		skip_auto_restart() {
			[ -f /etc/sysconfig/rpm ] && . /etc/sysconfig/rpm
			[ -f /etc/sysconfig/$service ] && . /etc/sysconfig/$service
			echo \${RPM_SKIP_AUTO_RESTART:-no}
		};
	EOF
}

echo ''
if [ "$check" = 1 ]; then
	skip_auto_restart_body
	echo 'if [ $(skip_auto_restart) = no ]; then'
		service_body
	echo 'fi'
else
	service_body
fi

exit 0

# for testing - no syntax errors allowed
rpm -E '%service monit restart' | sh
rpm -E '%service monit restart -q' | sh
rpm -E '%service monit stop' | sh
rpm -E '%service monit stop -q' | sh
rpm -E '%service monit stop "Monit Daemon"' | sh
rpm -E '%service monit stop "Monit Daemon" -q' | sh
rpm -E '%service monit restart "Monit Daemon"' | sh
rpm -E '%service monit restart -q "Monit Daemon"' | sh
rpm -E '%service monit reload "Monit Daemon"' | sh
rpm -E '%service monit reload -q "Monit Daemon"' | sh
rpm -E '%{service monit reload "Monit Daemon"} date' | sh
rpm -E '%{service monit reload "Monit Daemon" -q} date' | sh

