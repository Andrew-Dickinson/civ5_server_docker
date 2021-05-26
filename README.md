civ5_docker_server
==================

Scripts and Dockerfiles to install and run a dedicated Civilization 5 server on a headless, GPU-less Linux machine.

## How does it work? (briefly)

So Civ 5 Server is a Windows-only GUI application, that needs to render frames with ~~OpenGL~~ Direct3D (translated to
OpenGL with wine)... This Docker setup creates a virtual X11 framebuffer for Civ to render to, provides a VNC server so
you can remote in, installs Mesa such that the CPU can render frames (so no GPU needed), and libstrangle so that Civ
only runs at 2 FPS, so rendering doesn't consume the CPU so much (though it still takes an enormous amount of CPU time).

## How do you use it?

**1:** First, Civilization 5 needs to be installed into the `civ5game` directory, as well as the
`CivilizationV_Server.exe` file from the Civ 5 SDK.  You can copy those files over yourself, or use provided script as
`./install_civ.sh <steam_username> <steam_password>`.

**2:** Now you can build the container with `./build.sh`. This may take a while, most notably because it needs to fetch
and compile wine from source.

**3:** Now you can launch the container with `./run.sh`.

**4:** After the container starts running, you should be able to remote in with VNC. The `run.sh` script is set up to only
allow connections from localhost, so you'll want to open up an SSH tunnel if remoting in from a different machine first
(`ssh -NL 5900:127.0.0.1:5900 ${USERNAME}@${SERVER_IP}`).

Then, you should be able to point your VNC client at `localhost` and see Civ 5 running. Steam will also be running - it
needs to stay running the background for Civ to not crash, though you don't need to log in to it.

**5:** Setup the game through the VNC connection, and hope that it works and people can connect.

# Ports you might need to open/let through a firewall

`27016 UDP` is the only port you need to allow incoming traffic through. If you're just using plain `iptables` as a
firewall, bringing up the docker container should open that port for you.

## And now, a rant...

Just gonna copy-paste a chat log as I don't feel like typing this out again, lightly edited

> but anyways, civ 5 server is a windows-only gui applicaiton, that renders the entire game  
> and we have a linux server without a gpu  
> so: I install wine on the server in a container, install civ and the sdk into there too, copy the dedicated server executable into the game files  
> then I'm faffing around with figuring out what I need to install to get mesa (an OpenGL thing) up and running with software rendering, so civ 5 can render frames on the cpu instead of the cpu  
> also faffing around with getting X11 set up with just a framebuffer, so civ 5 has a display to render to (since the server doesn't have a monitor)  
> and also faffing around with getting a VNC or RDP or something server set up, so I can actually remote in to this virtual display (surprisingly painful)  
> try and launch civ now, aaand it immediately crashes  
> turns out the server needs a place to output audio to  
> so.. I install pulseaudio, so wine has a place to output audio to (even though it all gets ignored in the end)  
> launch civ  
> it makes it to the lobby setup screen, I hit host game  
> aaand crash  
> at this point, I'm faffing around with wine's debugger  
> and eventually figure out it ends up crashing on some Steam API call  
> ...turns out, Steam needs to be running in the background for civ to not crash EVEN THOUGH NO-BODY NEEDS TO BE LOGGED IN  
> so.. I install steam for windows in wine and what not, yada yada  
> aaand it..doesn't crash any more  
> woohoo  
> ...nobody can connect to the server  
> Steam has a list of ports it uses for server networking  
> civ 5 also says it uses one  
> so, ok let's poke those open in the firewall  
> still no-body can join  
> there's.. a lot of f---ing around here, but eventually the guy owning the server just gave up and gave us access to the firewall controls  
> some more faffing around later, we give up and just disable it  
> aaand it works  
> but enabled.. it doesn't  
> even though all the documented ports were open  
> oh yeah at some point we tried just using a full windows vm instead of wine  
> but anyways, I try installing wireshark now to monitor the packets going in/out while the firewall's down  
> aaand ohgod it's such a mess I can't tell anything apart  
> so I go to "Microsoft Message Analyzer", which at least lets me see what packets are comming from what applications...except when it doesn't  
> AAANYWAYS, more head scratching later, filtering out remote desktop traffic, telemetry traffic, traffic going to an ip owned by the us department of defence (!!?!?)  
> TURNS OUT civ, or steam, idk which one  
> just needs a whole several thousand port range open for UDP for it to work  
> that's just...not documented anywhere  
> \>.<  
> but uhh, yeah finally this is a thing  

(...in hindsight, the firewall issues was because we were filtering outgoing traffic and I didn't realize it >.<)

Now if you'll excuse me, I'm going to go curl up into a ball now and have nightmares about this.
