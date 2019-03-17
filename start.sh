#!/bin/bash
# **************************
# EDIT CONFIG SETTINGS BELOW
# **************************
# Installation config
install_location=/opt/space_engineers
# Wine config
wine_location=${install_location}/.wine64
# Screen config
screen_name=space_engineers

# ***************************
# DO NOT EDIT BELOW THIS LINE
# ***************************
procname=SpaceEngineersDedicated.exe
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

create_dir () {
    local dir=$1
    if [[ ! -d "${dir}" ]]
    then
        echo "Creating directory ${dir}..."
        mkdir ${dir}
    fi
}

is_wine_version_ok () {
    wine_version=$(get_wine_version)
    echo $"Found wine version ${wine_version}"
    numeric_wine_version="${wine_version//.}";

    if [[ ${numeric_wine_version} -ge 40 ]]
    then
        return 0
    fi

    return 1
}

is_winetricks_version_ok () {
    winetricks_version=$(get_winetricks_version)
    echo "Found winetricks version ${winetricks_version}"

    if [[ ${winetricks_version} -ge 20190310 ]]
    then
        return 0
    fi

    return 1
}

get_wine_version () {
    local wine_version=$(wine64 --version)
    echo "${wine_version//wine-}"
}

get_winetricks_version () {
    local winetricks_version=$(winetricks --version)
    echo "${winetricks_version:0:8}"
}

show_spinner() {
    spin='-\|/'
    i=0
    while kill -0 $2 2> /dev/null
    do
      i=$(( (i+1) %4 ))
      printf "\r$1 ${spin:$i:1}"
      sleep .1
    done

    echo -en "\r$1 done"
    echo ""
}

# Create installation directory and navigate to it
create_install_dir
cd ${install_location}

# Check wine version
if ! is_wine_version_ok ; then
    echo "ERROR: Wine version $(get_wine_version) is not 4.0 or newer"
    exit 1
fi

# Check winetricks version
if ! is_winetricks_version_ok ; then
    echo "ERROR: Winetricks version $(get_winetricks_version) is not 20190310 or newer"
    exit 1
fi

case "$1" in
        start)
                #login to steam and fetch the latest gamefiles
                cd ${install_location}/Steamcmd
                ./steamcmd.sh +force_install_dir ${wine_location}/drive_c/users/${whoami}/Desktop/spaceengineers +login anonymous +app_update 298740 -verify +quit
                cd ..

                #start the DS
                log_location=${install_location}/config/logs/server-$(date +%s).log
                cd ${wine_location}/drive_c/users/${whoami}/Desktop/spaceengineers/DedicatedServer64
                echo "Starting SpaceEngineersDedicated..."
                echo "Check log ${log_location} for more info"
                # Show the log in the console + log it immediately to a file
                WINEPREFIX=${wine_location} wine64 SpaceEngineersDedicated.exe -console | tee ${log_location}
                echo "Server has been stopped"
        ;;
        setup)  #run only once.
                echo "Press enter to confirm complete wipe of ${install_location}. If you have installed anything under the install directory and want to keep it, press Ctrl-C now!"
                read things
                echo "ARE YOU SURE?"
                read things
                echo "Wiping ${install_location}"
                rm -rf ${install_location}/*

                #grab steamcmd, make some directories.
                create_dir ${install_location}/config
                create_dir ${install_location}/client
                create_dir ${install_location}/config/backups
                create_dir ${install_location}/config/logs
                rm -rf ${install_location}/Steamcmd
                mkdir -p ${install_location}/Steamcmd
                cd ${install_location}/Steamcmd
                echo "Downloading SteamCMD"
                wget -q -O steamcmd_linux.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
                tar -xzf steamcmd_linux.tar.gz

                #configure our wine directory and make some symlinks
                cd ${install_location}
                echo "Configuring WINE and installing dependencies..."
                WINEDEBUG=-all WINEPREFIX=${wine_location} WINEARCH=win64 winecfg &> /dev/null & show_spinner "Configuring WINE" $!
                WINEDEBUG=-all WINEPREFIX=${wine_location} winetricks -q msxml3 &> /dev/null & show_spinner "Installing MSXML3" $!
                WINEDEBUG=-all WINEPREFIX=${wine_location} winetricks -q dotnet461 &> /dev/null & show_spinner "Installing .NET Framework" $!
                WINEDEBUG=-all WINEPREFIX=${wine_location} winetricks -q corefonts &> /dev/null & show_spinner "Installing COREFONTS" $!
                WINEDEBUG=-all WINEPREFIX=${wine_location} winetricks -q gdiplus &> /dev/null & show_spinner "Installing GDIPLUS" $!
                ln -s ${install_location} ${wine_location}/drive_c/users/${whoami}/Desktop/spaceengineers
                ln -s ${install_location}/config ${wine_location}/drive_c/users/${whoami}/Application\ Data/SpaceEngineersDedicated
                echo "Initial setup complete"

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
                        echo "$screen_name is running, not starting"
                        exit
                else
                        echo "$screen_name is not running, starting"
                        screen -dmS ${screen_name} -t ${screen_name} $0 start
                fi
        ;;
esac