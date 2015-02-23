<h1>SEDS-Setup</h1>

<h2>Description</h2>
It's a bash script for starting and configuring a Space Engineers server on a optionally headless Linux machine.

<a href="https://github.com/ArghArgh200/SEDS-Setup/issues">Report issues on the issues page. <B>MAKE SURE YOU LOOK THROUGH THEM FIRST.</B></a> Someone's probably already posted a solution, or it's a known bug.

<h2>Requirements</h2>

A Debian or Ubuntu-based OS (Others untested, use at own risk, <a href="https://github.com/ArghArgh200/SEDS-Setup/issues">report success/failures/tweaks to issues</a>)
A recent version of bash
WINE 1.7.30 or higher
WineTricks
Python 2.7 or higher
<code>unzip</code>
<code>wget</code>
<code>screen</code>

<h2>Usage</h2>

<h3>Step one: Download the script.</h3>
<pre><code>mkdir ~/spaceengineers
cd ~/spaceengineers
wget -O start.sh <a href="https://raw.githubusercontent.com/ArghArgh200/SEDS-Setup/master/start.sh">https://raw.githubusercontent.com/ArghArgh200/SEDS-Setup/master/start.sh</a>
chmod +x start.sh</pre></code>
The script is hardcoded to put your server in ~/spaceengineers. If you want to change that... good luck.

<h3>Step two: Check your wine version.</h3>
Run <code>wine --version</code> and also check if you have winetricks installed by running <code>which winetricks</code>

If your wine version is not 1.7.30 or higher the script will not work properly and I will absolutely refuse to help you.

<h3>Step three: Run the script's setup function</h3>
<pre><code>cd ~/spaceengineers
chmod +x start.sh
./start.sh setup</code></pre>
It'll ask you for your Steam user and password. Not to worry, your password is NOT saved anywhere on disk by my script. Your username is used at server start to check for updates, and is stored in plaintext at ~/spaceengineers/Steamcmd/.steamuser

<h3>Step four: Upload your configuration and start the server.</h3>
This is probably the most important part, and also the part where most of the stuff that can go wrong goes wrong.

Your configuration needs to go in <code>~/spaceengineers/config/SpaceEngineers-Dedicated.cfg</code>, your world in <code>~/spaceengineers/config/saves/SEDSWorld</code>, and your configuration's LoadWorld directive should point to C:\users\<your username>\Application Data\SpaceEngineersDedicated\Saves\SEDSWorld</code> in order for the server to Start right.


Alternatively you can just put the SpaceEngineers-Dedicated.cfg on the server, and have the server generate a world.


This should get you off the ground. I won't tell you how to make the configurations here, but there are numerous forum posts on the matter. <a href="http://forums.keenswh.com/post/6922069">Here's one you can use</a>. Hint: it involves running the dedicated server on your computer, generating a configuration using their program, and uploading it with some minor changes.

<h3>A note on changing server settings once you have a world made.</h3>

All server settings are overridden by the world's specific settings. The server name is one of the only things that isn't. If you want to add or remove mods, change the world's name or description, or refining speed/inventory sizes, you NEED to do it in the world! Use WinSCP or Filezilla to download the world folder to your local worlds, and edit the world via the game. If you have custom inventory limits or assembler speeds etc you'll have to open your Sandbox.sbc and edit them that way. BE CAREFUL! MAKE BACKUPS! Reckless editing of world files can and in most cases WILL break your world!

Now, run <code>./start.sh</code>, <code>screen -x spaceengineers</code>, and enjoy!

<h3>Automated World Backups using crontab</h3>
Add the following line in your crontab file:
<pre><code>*/A NUMBER * * * * /home/YOUR USERNAME/spaceengineers/start.sh backupworld</code></pre>
The number means that every that many minutes that go by, backup the world.

<h2>Planned features</h2>
Restarting the server safely every day

Completely clear installation every week/month, and reinstall, this can be done already by manually removing all but the .cfg, the world, and the script and running <code>./start.sh setup</code> again.

Credits to Andy_S and NolanSyKinsley of the space-engineers IRC channel on Esper for their tidbits, and <a href="http://forums.keenswh.com/post/7308307">Andy_S's NPC identity cleaner</a>.
