CI_LIBLNK=/usr/sfw/lib/mozilla/plugins/libjavaplugin_oji.so 
CI_LIBFILE=/opt/sun/jre/jre1.6.0_07/plugin/i386/ns7/libjavaplugin_oji.so 

OSVER=""
if [ `uname -r` = "5.10" ]; then
     OSVER="SOL10"
else
	 OSVER="SOL11"
fi

checkLib ()
{
  l_val=`ls -ltr $CI_LIBLNK | awk '{ print $1 }' | grep lrwxrwxrwx`
  if [ $? != 0 ]; then
	echo " $CI_LIBLNK is not softLink"
	exit 3
  fi
  
  l_libval=`ls -ltr $CI_LIBLNK |  awk '{ print $11 }'`
  if  [ $l_libval != $CI_LIBFILE ]; then
	echo "$l_libval  is NOT A SOFT link of $CI_LIBFILE"
	exit 4
  fi
  
}

#MAIN
if [ $OSVER == "SOL10" ] ; then
	checkLib
fi
exit 0
