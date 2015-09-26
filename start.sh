#!/bin/bash
#put this script in ~/spaceengineers/start.sh
#run 'chmod +x ~/spaceengineers/start.sh'
#and '~/spaceengineers/start.sh setup'
service=spaceengineers
procname=SpaceEngineersDedicated.exe
cd $HOME/spaceengineers
WINEDEBUG=-all
whoami=`whoami` #but who AM I, really?
case "$1" in
        start)
                #login to steam and fetch the latest gamefiles
                cd $HOME/spaceengineers
                cd Steamcmd
                ./steamcmd.sh +force_install_dir $HOME/.wine/drive_c/users/$whoami/Desktop/spaceengineers +login anonymous +app_update 298740 -verify +quit
                cd ..

                #clear old binaries and get new ones
                cd config/Saves/SEDSWorld
                echo "Cleaning world of dead NPC entries - Credits to Andy_S of #space-engineers"
                wget -q -O ../../worldcleaner.py https://github.com/deltaflyer4747/SE_Cleaner/raw/master/clean.py
                python ../../worldcleaner.py

                #start the DS
                cd $HOME/.wine/drive_c/users/$whoami/Desktop/spaceengineers/DedicatedServer
                WINEDEBUG=-all wine SpaceEngineersDedicated.exe -console
                logstamper=`date +%s`

                #copy server world and log to backups and logs directories
                cd ../config
                mv SpaceEngineersDedicated.log logs/server-$logstamper.log
                cp -rf Saves/SEDSWorld backups/world-$logstamper-svhalt
        ;;
        setup)  #run only once.
                echo "Press enter to confirm complete wipe of your WINE's configuration directory. If you have installed anything under regular WINE and want to keep it, press Ctrl-C now!"
                read things
                echo "ARE YOU SURE?"
                read things
                echo "ARE YOU REALLY SURE?"
                read things
                echo "Wiping WINE installation."
                rm -rf $HOME/.wine

                #grab steamcmd, make some directories.
                mkdir $HOME/spaceengineers/config
                mkdir $HOME/spaceengineers/client
                mkdir $HOME/spaceengineers/config/backups
                mkdir $HOME/spaceengineers/config/logs
                rm -rf $HOME/spaceengineers/Steamcmd
                mkdir -p $HOME/spaceengineers/Steamcmd
                cd $HOME/spaceengineers/Steamcmd
                echo "Downloading SteamCMD"
                wget -q -O steamcmd_linux.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
                tar -xzf steamcmd_linux.tar.gz

                #configure our wine directory and make some symlinks
                cd $HOME
                echo "Configuring WINE and installing dependencies."
                WINEDEBUG=-all WINEARCH=win32 winecfg > /dev/null
                WINEDEBUG=-all winetricks -q msxml3 > /dev/null
                WINEDEBUG=-all winetricks -q dotnet40 > /dev/null
                ln -s $HOME/spaceengineers $HOME/.wine/drive_c/users/$whoami/Desktop/spaceengineers
                ln -s $HOME/spaceengineers/config $HOME/.wine/drive_c/users/$whoami/Application\ Data/SpaceEngineersDedicated
                echo "Initial setup complete."

                #install and update steamcmd
                echo "Installing and updating SteamCMD"
                #run twice because the first time we need to make steamcmd download its files before attempting a login
                cd $HOME/spaceengineers/Steamcmd/
                ./steamcmd.sh +exit
                ./steamcmd.sh +login anonymous +exit
                echo "Setup complete. Please place your server's .cfg file in ~/spaceengineers/config/SpaceEngineers-Dedicated.cfg.  You'll need to edit it and change the <LoadWorld /> part to read: <LoadWorld>C:\users\\$whoami\Application Data\SpaceEngineersDedicated\Saves\SEDSWorld</LoadWorld>."
        ;;
        backupworld) #put an entry in your crontab pointing to this script with the first argument being 'backupworld'.
                logstampworld=`date +%s`
                cd $HOME/spaceengineers/config
                cp -rf Saves/SEDSWorld backups/world-$logstampworld
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
