#!/bin/bash
#put this script in ~/spaceengineers/start.sh
#run 'chmod +x ~/spaceengineers/start.sh'
#and '~/spaceengineers/start.sh setup'
service=spaceengineers
procname=SpaceEngineersDedicated.exe
cd $HOME/spaceengineers
WINEDEBUG=-all
whoami=`whoami` #but who AM I, really?
# Wine config
wine_location=$HOME/.wine64

case "$1" in
        start)
                if is_wine_version_ok ;
                then
                    #login to steam and fetch the latest gamefiles
                    cd $HOME/spaceengineers
                    cd Steamcmd
                    ./steamcmd.sh +force_install_dir ${wine_location}/drive_c/users/$whoami/Desktop/spaceengineers +login anonymous +app_update 298740 -verify +quit
                    cd ..

                    #start the DS
                    cd ${wine_location}/drive_c/users/$whoami/Desktop/spaceengineers/DedicatedServer
                    WINEDEBUG=-all wine64 SpaceEngineersDedicated.exe -console
                    logstamper=`date +%s`

                    #copy server world and log to backups and logs directories
                    cd ../config
                    mv SpaceEngineersDedicated.log logs/server-$logstamper.log
                    cp -rf Saves/SEDSWorld backups/world-$logstamper-svhalt
                 el
                    echo "Wine version is not 4.0 or newer"
                 fi
        ;;
        setup)  #run only once.
                echo "Press enter to confirm complete wipe of your WINE's configuration directory. If you have installed anything under regular WINE and want to keep it, press Ctrl-C now!"
                read things
                echo "ARE YOU SURE?"
                read things
                echo "ARE YOU REALLY SURE?"
                read things
                echo "Wiping WINE installation."
                rm -rf ${wine_location}

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
                WINEDEBUG=-all WINEARCH=win64 winecfg > /dev/null
                WINEDEBUG=-all winetricks -q msxml3 > /dev/null
                WINEDEBUG=-all winetricks -q dotnet461 > /dev/null
                WINEDEBUG=-all winetricks -q corefonts > /dev/null
                WINEDEBUG=-all winetricks -q gdiplus > /dev/null
                ln -s $HOME/spaceengineers ${wine_location}/drive_c/users/$whoami/Desktop/spaceengineers
                ln -s $HOME/spaceengineers/config ${wine_location}/drive_c/users/$whoami/Application\ Data/SpaceEngineersDedicated
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

is_wine_version_ok() {
    wine_version=$"{`wine64 --version`/wine-/}"
    echo $"Found wine version ${wine_version}"
    wine_major_version="${wine_version:0:1}";
    result=false

    if [[ ${wine_major_version} = "4" ]]
    then
        result=true
    fi

    return result
}
