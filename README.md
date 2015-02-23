<h1>SEDS-Setup</h1><br>
Script for starting and configuring a Space Engineers server on a optionally headless Linux machine.<br>
Report issues on the issues page. MAKE SURE YOU LOOK THROUGH THEM FIRST. Someone's probably already posted a solution.<br>
<br>
<h2>Usage</h2><br>
<h3>Step one: Download the script.</h3><br>
<pre><code>mkdir ~/spaceengineers<br>
cd ~/spaceengineers<br>
wget -O start.sh link-to-start.sh<br>
chmod +x start.sh</pre></code><br>
The script is hardcoded to put your server in ~/spaceengineers. If you want to change that... good luck.<br>
<h3>Step two: Check your wine version.</h3><br>
Run <code>wine --version</code> and also check if you have winetricks installed. Run <code>which winetricks</code><br>
If your wine version is not 1.7.30 or higher the script will not run and I will close any issue tickets you make until you upgrade.<br>
<h3>Step three: Run the script's setup function</h3><br>
<pre><code>cd ~/spaceengineers<br>
chmod +x start.sh<br>
./start.sh setup</pre></code><br>
It'll ask you for your Steam user and password. Not to worry, your password is NOT saved anywhere on disk. Your username is used at server start to check for updates, and is stored in plaintext at ~/spaceengineers/Steamcmd/.steamuser<br>
It'll probably ask for you to download some links and put them in a folder. You may have to run the script twice.<br>
<h3>Step four: Upload your configuration and start the server.</h3><br>
This is probably the most important part, and also the part where most of the stuff that can go wrong goes wrong.<br>
Your configuration needs to go in <code>~/spaceengineers/config/SpaceEngineers-Dedicated.cfg</code>, your world in <code>~/spaceengineers/config/saves/SEDSWorld</code>, and your configuration's LoadWorld directive should point to C:\users\<your username>\Application Data\SpaceEngineersDedicated\Saves\SEDSWorld</code> in order for the server to even begin functioning.<br>
Alternatively you can just put the SpaceEngineers-Dedicated.cfg on the server, and have the server generate a world.<br>
This should get you off the ground. I won't tell you how to make the configurations here, but there are numerous forum posts on the matter. [Here's one you can use.]<http://forums.keenswh.com/post/tutorial-dedicated-server-on-ubuntu-13-10-using-wine-6922069><br>
Hint: it involves running the dedicated server on your computer, generating a configuration using their program, and uploading it with some minor changes.<br>
<h3>A note on changing server settings once you have a world made.</h3><br>
All server settings are overridden by the world's specific settings. The server name is one of the only things that isn't. If you want to add or remove mods, change the world's name or description, or refining speed/inventory sizes, you NEED to do it in the world! Use WinSCP or Filezilla to download the world folder to your local worlds, and edit the world via the game. If you have custom inventory limits or assembler speeds etc you'll have to open your Sandbox.sbc and edit them that way. BE CAREFUL! MAKE BACKUPS! Reckless editing of world files can and in most cases WILL break your world!<br>
Now, run <code>./start.sh</code>, <code>screen -x spaceengineers</code>, and enjoy!<br>
<h3>Automated World Backups using crontab</h3><br>
Add the following line in your crontab file:<br>
<pre><code>*/A NUMBER * * * * /home/YOUR USEvRNAME/spaceengineers/start.sh backupworld</code></pre><br>
The number means that every that many minutes that go by, run the script.<br>
Credits to Andy_S and NolanSyKinsley of the <h1>space-engineers IRC channel on Esper for their tidbits, and Andy_S's NPC identity cleaner.</h1><br>
