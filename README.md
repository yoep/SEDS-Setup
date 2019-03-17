# SEDS-Setup-Revived

#### Works with Space Engineers version 1.189 (Survival Overhaul)

This is a revived project for the original [SEDS-setup](https://github.com/DJArghlex/SEDS-Setup) as the original author has archived the project.

## Description
SEDS-Setup a bash script for starting and configuring a Space Engineers Dedicated Server on a Linux machine inside GNU screen.

## Requirements

    wine (4.0+)
    winetricks (20190310 or newer)
    cabextract
    winbind
    wget
    screen

## Usage

### Step one: Download the script

	wget -O start.sh https://raw.githubusercontent.com/yoep/SEDS-Setup/master/start.sh
	chmod +x start.sh

### Step two: Edit script configuration

Edit "start.sh" with an editor
        
    nano start.sh

Only edit the information below the "EDIT CONFIG SETTINGS BELOW" section.

### Step three: Run the script's setup function

	chmod +x start.sh
	./start.sh setup

### Step four: Upload your configuration and start the server.

This is probably the most important part, and also the part where most of the stuff that can go wrong goes wrong.

#### Place the configuration and world in the following locations:

**Server Configuration**

    {install_location}/config/SpaceEngineers-Dedicated.cfg

**World save**

    {install_location}/config/Saves/{world_name}

#### Now edit the server configuration file and make the following changes:

Update `<LoadWorld>` option so it points to the following directory

    <LoadWorld>C:\users\<your username>\Application Data\SpaceEngineersDedicated\Saves\{world_name}</LoadWorld>
    
Edit the `<IP>` to the IP address of your server.
(There is currently an issue with the DHCP auto assigning of the IP address in Wine 4.0 which will crash the dedicated server)

    <IP>XXX.XXX.XXX.XXX</IP>

### A note on changing server settings once you have a world made.

All server settings are overridden by the world's specific settings. The server name is one of the only things that isn't. If you want to add or remove mods, change the world's name or description, or refining speed/inventory sizes, you NEED to do it in the world! Use WinSCP or Filezilla to download the world folder to your local worlds, and edit the world via the game. If you have custom inventory limits or assembler speeds etc you'll have to open your Sandbox.sbc and edit them that way. BE CAREFUL! MAKE BACKUPS! Reckless editing of world files can and in most cases WILL break your world!

Now, run *./start.sh*, *screen -x spaceengineers*, and enjoy!

### Automated World Backups using crontab
Add the following line in your crontab file:

	*/15 * * * * $HOME/spaceengineers/start.sh backupworld
	
This means that every 15 minutes that go by, backup the world.

## Planned features
1. Restarting the server safely every day
1. Completely clear installation every week/month, and reinstall, this can be done already by manually removing all but the .cfg, the world, and the script and running *./start.sh setup* again.

Credits to Andy_S and NolanSyKinsley of the #space-engineers IRC channel on Esper for their information.
