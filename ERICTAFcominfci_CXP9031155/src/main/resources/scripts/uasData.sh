CI_SHM_SCRIPT=clear_unused_shmids.sh
CI_CRONTAB=/usr/bin/crontab

OSVER=""
if [ `uname -r` = "5.10" ]; then
     OSVER="SOL10"
else
	 OSVER="SOL11"
fi

CheckCrontEntry ()
{
  $CI_CRONTAB -l | grep $CI_SHM_SCRIPT
  if [ $? != 0 ]; then
  echo "$CI_SHM_SCRIPT is not an crontab entry"
  exit 4
  fi
}


#MAIN
if [ $OSVER == "SOL10" ] ; then
CheckCrontEntry
fi
exit 0 
