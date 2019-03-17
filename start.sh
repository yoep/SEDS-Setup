#!/bin/bash
# **************************
# EDIT CONFIG SETTINGS BELOW
# **************************
# Installation config
install_location=/opt/space_engineers
# Wine config
wine_location=${install_location}/.wine64

# ***************************
# DO NOT EDIT BELOW THIS LINE
# ***************************
service=spaceengineers
procname=SpaceEngineersDedicated.exe
WINEDEBUG=-all
whoami=`whoami` #but who AM I, really?

create_install_dir () {
    if [[ ! -d "${install_location}" ]]
    then
        echo "Creating installation directory ${install_location}..."
        sudo mkdir ${install_location}
        sudo chown -R ${whoami} ${install_location}
        echo "Done creating installation directory"
    fi
}

is_wine_version_ok () {
    wine_version=$(get_wine_version)
    echo $"Found wine version ${wine_version}"
    numeric_wine_version="${wine_version//.}";
    result=1

    if [[ ${numeric_wine_version} -ge 40 ]]
    then
        result=0
    fi

    return ${result}
}

get_wine_version () {
    local wine_version=$(wine64 --version)
    echo "${wine_version//wine-}"
}

# Create installation directory and navigate to it
create_install_dir
cd ${install_location}

# Check wine version
if ! is_wine_version_ok ; then
    echo "ERROR: Wine version $(get_wine_version) is not 4.0 or newer"
    exit 1
fi

case "$1" in
        start)
                #login to steam and fetch the latest gamefiles
                cd ${install_location}/Steamcmd
                ./steamcmd.sh +force_install_dir ${wine_location}/drive_c/users/${whoami}/Desktop/spaceengineers +login anonymous +app_update 298740 -verify +quit
                cd ..

                #start the DS
                cd ${wine_location}/drive_c/users/${whoami}/Desktop/spaceengineers/DedicatedServer
                WINEDEBUG=-all wine64 SpaceEngineersDedicated.exe -console
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
                rm -rf ${wine_location}

                #grab steamcmd, make some directories.
                mkdir ${install_location}/config
                mkdir ${install_location}/client
                mkdir ${install_location}/config/backups
                mkdir ${install_location}/config/logs
                rm -rf ${install_location}/Steamcmd
                mkdir -p ${install_location}/Steamcmd
                cd ${install_location}/Steamcmd
                echo "Downloading SteamCMD"
                wget -q -O steamcmd_linux.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
                tar -xzf steamcmd_linux.tar.gz

                #configure our wine directory and make some symlinks
                cd ${install_location}
                echo "Configuring WINE and installing dependencies."
                WINEDEBUG=-all WINEARCH=win64 winecfg > /dev/null
                WINEDEBUG=-all winetricks -q msxml3 > /dev/null
                WINEDEBUG=-all winetricks -q dotnet461 > /dev/null
                WINEDEBUG=-all winetricks -q corefonts > /dev/null
                WINEDEBUG=-all winetricks -q gdiplus > /dev/null
                ln -s ${install_location} ${wine_location}/drive_c/users/${whoami}/Desktop/spaceengineers
                ln -s ${install_location}/config ${wine_location}/drive_c/users/${whoami}/Application\ Data/SpaceEngineersDedicated
                echo "Initial setup complete."

                #install and update steamcmd
                echo "Installing and updating SteamCMD"
                #run twice because the first time we need to make steamcmd download its files before attempting a login
                cd ${install_location}/Steamcmd/
                ./steamcmd.sh +exit
                ./steamcmd.sh +login anonymous +exit
                echo "Setup complete. Please place your server's .cfg file in ${install_location}/config/SpaceEngineers-Dedicated.cfg.  You'll need to edit it and change the <LoadWorld /> part to read: <LoadWorld>C:\users\\$whoami\Application Data\SpaceEngineersDedicated\Saves\SEDSWorld</LoadWorld>."
        ;;
        backupworld) #put an entry in your crontab pointing to this script with the first argument being 'backupworld'.
                logstampworld=`date +%s`
                cd ${install_location}/config
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