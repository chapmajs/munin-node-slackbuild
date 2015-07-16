# Post-install configuration scripts, borrowed from the fail2ban
# Slackbuild: 

config() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "$(cat $OLD | md5sum)" = "$(cat $NEW | md5sum)" ]; then
    # toss the redundant copy
    rm $NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}

preserve_perms() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  if [ -e $OLD ]; then
    cp -a $OLD ${NEW}.incoming
    cat $NEW > ${NEW}.incoming
    mv ${NEW}.incoming $NEW
  fi
  config $NEW
}

preserve_perms etc/rc.d/rc.munin-node.new
config etc/munin/munin-node.conf.new
config etc/logrotate.d/munin-node.new

# Add users and groups, if they don't exist
/usr/bin/getent passwd munin > /dev/null
if [ $? -ne 0 ]; then
	groupadd -g 434 munin
fi

/usr/bin/getent passwd munin > /dev/null
if [ $? -ne 0 ]; then
	useradd -u 434 -g 434 -s /sbin/nologin munin
fi
