# MacOS Minecraft Timer for (Technically Inclined) Parents

IF YOU ARE A PARENT and your family has at least one or two Apple devices, one of them being a MacBook, you most likely have Minecraft installed on it. And suppose you are a parent who manages the time your kids spend on these devices using Apple's Screen Time functionality. In that case, you probably know that using Minecraft on a MacBook doesn't get included in the list of apps you can monitor. This is because Minecraft runs on Java, and Java is omitted from that list. The most probable reason is that Java is an old, not entirely secure technology that is not included natively in the Apple ecosystem. Request for being able to monitor Minecraft has been aired. Still, it is [deemed not worthy of recognition by Mojang](https://bugs.mojang.com/browse/MCL-14705), and Apple, I guess, is in the same boat.

So that leaves us, parents, to figure this out ourselves. Enter my very crude attempt to at least go in that direction. I have created a script that, utilizing macOS functionalities, will periodically check to see if Java (and Minecraft) is running. After a given time, it will issue a warning saying that the pre-determined time is up. Now, I am not, and I repeat, **not** a macOS/Shell programmer, so this is a crude, limited and probably even a poor attempt to partially solve this issue. So if you are going to use it, use it with caution and at your own risk, etcetera. Also, please feel free to build upon it if you share your improvements with others. And I should mention that you will need to be a tad knowledgeable about fiddling with macOS files, permissions and so on if you want to give this a shot. Also, if you start adding this to a MacBook with multiple users, one of them being your kid's account, you will probably run into file permission issues.

**It has only been created and tested on macOS Monterey 12.5.1.** Basically, I have just thrown it out here for grabs. I, unfortunately, do not have time to try it on other macOS platforms, make a friendly installer etc.

This is how it works: The main script (here called *MinecraftTimer.sh*) will have to reside somewhere on the system where the kids usually don't look. In this example, I placed it in the */usr/local/bin/* folder. This script needs to be executable, so in macOS Terminal, you need to do this by this command:

```
% chmod 755 /usr/local/bin/MinecraftTimer.sh
```

You can also test the script on your version of macOS via Terminal to see if any issues pop up.

A [launchd file](https://www.launchd.info) (or .plist file - a kind of Mac XML file) can be triggered whenever the current user logs in and start using the Mac. And this can in turn trigger a script like the MinecraftTimer.sh script. This .plist file is placed in the *\~/Library/LaunchAgents/* folder (the current user's LaunchAgents folder). It can be re-triggered periodically, so that is what this one does, launching, in turn, our *MinecraftTimer.sh* script every 60 seconds. Then this script saves a preference file (in the */tmp/* directory) which it uses to keep time throughout the day – even if Minecraft quits and then gets relaunched later. If this preference or log file is before midnight on the current day, it creates a fresh one, so the timer is resetting every day.

A warning is triggered just before the allotted time ends, asking the gamer to please save and quit unless they have permission to continue. I have not included a "quit-and-disable-Java" command in the script. This is because I believe in communicating with my kids regarding their limits, not being forceful unless I absolutely have to. Still, you can modify this if you know how.

The main Shell script should be placed in the */usr/local/bin/* folder. If you put it elsewhere, you will need to change the path to the location in the XML/launchd file. Note that you can change the allowed time by changing the *MAX_TIME=60* variable to any minutes you want. Say, for two hours, it will be *MAX_TIME=120* and so on.

The launchd file should be placed in the *\~/Library/LaunchAgents/* folder. Name it something unique like *com.your_name.MinecraftTimer.plist*. If you like, you can change the *StartInterval* to something different. The 60 stands for 60 seconds, so the script above gets executed every minute.

Enjoy!
