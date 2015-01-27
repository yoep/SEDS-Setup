#!/bin/bash
service=spaceengineers
procname=SpaceEngineersDedicated.exe
cd $HOME/spaceengineers
WINEDEBUG=-all
whoami=`whoami` #but who AM I, really?
case "$1" in
        start)
                #login to steam and fetch the latest gamefiles
                cd $HOME/spaceengineers
                steamuser=`cat .steamuser`
                cd Steamcmd
                WINEDEBUG=-all wine steamcmd.exe +force_install_dir C:\\users\\$whoami\\Desktop\\spaceengineers\\client +login $steamuser +app_update 244850 -verify +quit
                cd ..

                #clear old binaries and get new ones
                rm -rf DedicatedServer DedicatedServer64 Content
                unzip client/Tools/DedicatedServer.zip
                cd config

                #start the DS
                cd $HOME/.wine/drive_c/users/$whoami/Desktop/spaceengineers/DedicatedServer
                WINEDEBUG=-all wine SpaceEngineersDedicated.exe -console
                logstamper=`date +%s`

                #copy server world and log to backups and logs directories
                cd ../config
                mv SpaceEngineersDedicated.log logs/server-$logstamper.log
                cp -rf Saves/SBGSEWorld backups/world-$logstamper-svhalt
        ;;
        setup)  #run only once.
                echo "Press enter to confirm complete wipe of your WINE's configuration directory. If you have installed anything under regular WINE and want to keep it, do not press enter!"
                read things
                echo "ARE YOU SURE?"
                read things
                echo "ARE YOU REALLY SURE?"
                read things
                rm -rf $HOME/.wine

                #grab steamcmd, make some directories.
                mkdir $home/spaceengineers/config
                mkdir $home/spaceengineers/config/backups
                mkdir $home/spaceengineers/config/logs
                mkdir -p $HOME/spaceengineers/Steamcmd
                cd $HOME/spaceengineers/Steamcmd
                wget -O steamcmd.zip http://media.steampowered.com/installer/steamcmd.zip
                unzip steamcmd.zip

                #configure our wine directory and make some symlinks
                cd $HOME
                echo "configuring WINE and installing dependencies."
                WINEARCH=win32 winecfg
                winetricks -q msxml3
                winetricks -q dotnet40
                wget -O $HOME/.wine/drive_c/windows/system32/oleaut32.dll http://pitchblack.arghlex.net/oleaut32.dll
                ln -s $HOME/.wine/drive_c/users/$whoami/Desktop/spaceengineers $HOME/spaceengineers/
                ln -s $HOME/.wine/drive_c/users/$whoami/Application\ Data/SpaceEngineersDedicated $HOME/spaceengineers/config/

                #login to steam for the first time, and allow steamcmd to run itself
                echo "We'll now try and run steamcmd. In order to install the DS, you need to have a steam account with the game purchased and activated."
                echo "Steam username:"
                read steamuser
                echo $steamuser > $HOME/spaceengineers/.steamuser
                echo "Steam password (Not stored, if you have steamguard enabled like a smart person, go get the code when it asks for one.):"
                read steampass
                #run twice because the first time we need to make steamcmd download its files before attempting a login
                WINEDEBUG=-all wine steamcmd.exe +exit
                WINEDEBUG=-all wine steamcmd.exe +login $steamuser $steampass +exit
                echo "If you did not see something download above this line, something went wrong. Get on the forums and ask around."
                echo "Alright, now that you have the dedicated server installed, go make a config with the copy your game files have locally. You'll need to edit it and change the <LoadWorld /> part to look (roughly) like this: <LoadWorld>C:\users\<your username>\Application Data\SpaceEngineersDedicated\Saves\YourWorldName</LoadWorld>."
                echo "Donate to keep things like this going! http://arghlex.net/?page=donators !"
        ;;
        backupworld) #put an entry in your crontab pointing to this script with the first argument being 'backupworld'.
                logstampworld=`date +%s`
                cd $HOME/spaceengineers/config
                cp -rf Saves/SBGSEWorld backups/world-$logstampworld
        ;;
        *)
                if ps ax | grep -v grep | grep $procname > /dev/null
                then
                        echo "$service is running, not starting"
                        exit
                else
                        echo "$service is not running, starting"
                        screen -dmS $service -t $service $0 start
                fi
        ;;
esac
