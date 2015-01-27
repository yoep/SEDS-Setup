# SEDS-Setup

Script for starting and configuring a Space Engineers server on a (optionally headless) Linux machine.

Report issues on the issues page. MAKE SURE YOU LOOK THROUGH THEM FIRST. Someone's probably already posted a solution.


##Usage

###Step one: Download the script.

<pre><code>mkdir ~/spaceengineers
cd ~/spaceengineers
wget -O start.sh [https://github.com/ArghArgh200/SEDS-Setup/raw/master/start.sh](<https://github.com/ArghArgh200/SEDS-Setup/raw/master/start.sh>)</pre></code>

The script is hardcoded to put your server in ~/spaceengineers. If you want to make it less... hardcoded feel free to do so and share it back with me.

###Step two: Check your wine version.

Run <code>wine --version</code> and also check if you have winetricks installed. (Run <code>which winetricks</code>)

If your wine version is not 1.7.30 or higher the script will not run and I will close any issue tickets you make until you upgrade.

###Step three: Run the script's setup function

<pre><code>cd ~/spaceengineers
chmod +x start.sh
./start.sh setup</pre></code>

It'll ask you for your Steam user and password. Not to worry, your password is NOT saved anywhere on disk. (Your username is used at server start to check for updates, and is stored in plaintext at ~/spaceengineers/.steamuser )

It'll probably ask for you to download some links and put them in a folder. You may have to run the script twice.

###Step four: Upload your configuration and start the server.

This is probably the most important part, and also the part where most of the stuff that can go wrong goes wrong.

Your configuration needs to go in <code>~/spaceengineers/config/SpaceEngineers-Dedicated.cfg</code>, your world in <code>~/spaceengineers/config/saves/<Your World></code>, and your configuration's LoadWorld directive should point to C:\users\<your username>\Application Data\SpaceEngineersDedicated\Saves\<Your World></code>.

This should get you off the ground. I won't tell you how to make the configurations here, but there are numerous forum posts on the matter. [Here's one you can use.](<http://forums.keenswh.com/post/tutorial-dedicated-server-on-ubuntu-13-10-using-wine-6922069>)

##Old instructions from my forum post for setting up a DS on linux under wine.

###(These instructions are not for a beginning user, they're for someone who has compiled programs themselves and been administrating Linux machines for a living or as a hobby.)

###(Side note #2: if you have wine 1.7.30 or newer, you're probably fine and don't need to compile it yourself.)

Install wine's 32-bit dependencies using whatever package manager your OS uses. At the VERY LEAST, install libpng's development libraries, libjpg's development libraries, and I believe GnuTLS's development libraries.

Grab a WINE 1.7 source package from their site and make sure you've got your 32-bit compilers and whatnot installed. Their site also has a list of packages you can install if you want a more complete WINE install.

Install winetricks and GNU screen ('screen' in most package databases). You'll need them later.

Compile WINE. You will want to put it in a GNU screen instance. It'll take about an hour: 

<pre><code>cd wine-1.7.xx
./configure --without-x --without-freetype
make
sudo make install</pre></code>





While your compile is going, exit out of the screen (or make a new window in it) and start uploading your DedicatedServer.zip and then follow STEPS TWO THROUGH FOUR ONLY on the [Running DS under WINE on Ubuntu 13.10](<http://forums.keenswh.com/post/tutorial-dedicated-server-on-ubuntu-13-10-using-wine-6922069>) thread.

After WINE's done compiling, you need to setup WINE to use its 32-bit binaries otherwise some nasty things happen when installing dotnet40. WARNING: If you've used WINE on this user's account before, these commands will delete any Windows programs installed!

<pre><code>cd ~
rm -rf ~/.wine
WINEARCH=win32 winecfg</pre></code>

You now need an oleaut32.dll from a reputable source. I used 7-zip to open [this Microsoft installer that contained it](<http://support.microsoft.com/kb/180071/EN-US>) and uploaded it to my server. Windows XP users (Upgrade to 7 or 8.1 already. You're not helping yourself by staying on XP) can just grab their copy from their system32 directory. ***DO NOT INSTALL VB6RUN LIKE SOME ARE SAYING. THIS CAUSES PROBLEMS IN A LOT OF PLACES FOR THOSE OF YOU WITH HEADLESS SERVERS!!**** (But if it doesn't work, try clearing your WINE directory, starting over, and installing vb6run via winetricks.) The DLL goes in ~/.wine/drive_c/windows/system32/, overwriting the existing one.

Check that you've installed winetricks. If you have:

<pre><code>winetricks -q msxml3
winetricks -q dotnet40</pre></code>

Now, that should (READ: should) put your server in working order if you have more than 2GB of RAM and a sizable CPU. Check your configuration you created using AdamAnt's guide, and you should be good to go. I used a series of symlinks to keep my Space Engineers server installation outside my WINE install in case I need to clear it:

<pre><code>mkdir ~/spaceengineers
cd spaceengineers
mkdir config
unzip DedicatedServer.zip
cd ~/.wine/drive_c/users/${whoami}/Application Data/
ln -s /home/${whoami}/spaceengineers/config/ SpaceEngineersDedicated
cd ../Desktop/
ln -s /home/${whoami}/spaceengineers/ spaceengineers
cd ~</pre></code>

...And put your config files from the other guide in ~/spaceengineers/config/, not ~/.wine/drive_c/users/<server username>/Application Data/SpaceEngineersDedicated/, and your binaries in ~/spaceengineers/, so that you get something looking like this:

<pre><code>~/spaceengineers/
  |- DedicatedServer.zip
  |- DedicatedServer/
  |  |- SpaceEngineersDedicated.exe
  |  \- <A ton of DLLs and other files>
  |- DedicatedServer64/
  |- Content/
  |- A backup of oleaut32.dll from earlier.
  |- config/
    |- Saves/
    |  \- Your world file
    |- SpaceEngineers-Dedicated.cfg
    \- SpaceEngineersDedicated.log</pre></code>

Write some quick scriptlet to start your server without a hassle. I'll post mine just as a base point:

<pre><code>#!/bin/bash
cd $HOME/.wine/drive_c/users/${whoami}/Desktop/spaceengineers/
screen -dmS spaceengineers -t spaceengineers wine SpaceEngineersDedicated.exe -console
screen -x spaceengineers</pre></code>

Credits to Andy_S of the #space-engineers IRC channel on Esper.
