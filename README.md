# SEDS-Setup-Revived
#### Space Engineers Dedicated Server
#### Works with Space Engineers version 1.192 (Economy Update)

This is a revived project for the original [SEDS-setup](https://github.com/DJArghlex/SEDS-Setup) as the original author has archived the project.

## Description
SEDS-Setup a bash script for starting and configuring a Space Engineers Dedicated Server on a Linux machine inside GNU screen.

## Requirements

    wine (4.0+)
    winetricks (20190912 or newer)
    cabextract
    winbind
    wget
    screen

## Usage

### Step one: Download the script

	wget -O space_engineers.sh https://raw.githubusercontent.com/yoep/SEDS-Setup/master/space_engineers.sh
	chmod +x space_engineers.sh

### Step two: Edit script configuration

Edit "space_engineers.sh" with an editor
        
    nano space_engineers.sh

Only edit the information below the "EDIT CONFIG SETTINGS BELOW" section.

### Step three: Run the script's setup function

	chmod +x space_engineers.sh
	./space_engineers.sh setup

### Step four: Upload your server configuration

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

### Step Five: Start the server

You have 2 options to start the server, the first one is running it in your current session or the second one is starting it in a screen session.

**Running directly**

    ./space_engineers.sh start
    
**In a screen session**

    ./space_engineers.sh

### A note on changing server settings once you have a world made.

All server settings are overridden by the world's specific settings. The server name is one of the only things that isn't. If you want to add or remove mods, change the world's name or description, or refining speed/inventory sizes, you NEED to do it in the world! Use WinSCP or Filezilla to download the world folder to your local worlds, and edit the world via the game. If you have custom inventory limits or assembler speeds etc you'll have to open your Sandbox.sbc and edit them that way. BE CAREFUL! MAKE BACKUPS! Reckless editing of world files can and in most cases WILL break your world!

Now, run *./space_engineers.sh*, *screen -x spaceengineers*, and enjoy!

### Automated World Backups using crontab
Add the following line in your crontab file:

	*/15 * * * * $HOME/spaceengineers/space_engineers.sh backupworld
	
This means that every 15 minutes that go by, backup the world.

## Known issues

* Creating new worlds doesn't work
* IP address not being assigned to the dedicated server (workaround: restart the dedicated server)

Credits to Andy_S and NolanSyKinsley of the #space-engineers IRC channel on Esper for their information.
