# WSL Bridge

A PowerShell script that allows you to bridge ports between your WSL 2 virtual environment and the Windows host, by changing port forwarding and firewall rules on the host machine.

## What this is for

If you ever found yourself developing something in WSL (say, a website using Node.js and Vue.js) and wanted to connect external devices to the address and port being used by the application server, you may have noticed that external devices get a `CONNECTION REFUSED` error when trying to reach the running service. Or you might have tried using `localhost` on the host machine which got you to right place, but inputting your machine's IP address (which should be what `localhost` is an alias of) gives you a similar error as described above.

This error happens (as far as I'm aware) because even though Windows binds `localhost` ports between the virtual linux environment and itself automatically, it doesn't seem to do that for its own static IP. What happens, then, is that if you have a certain WSL process running on a certain port and use an external device to ask Windows to be connected with that port, Windows does not look at WSL ports and subsequently refuses the connection request, because it decides that there are no processes bound to that port.

This tool will allow you to specify which port(s) you want shared (forwarded, if you will) between the host and WSL, and then it will set new firewall and port forwarding rules to tell Windows to look for WSL processes running in the specified port(s).

## How does it work?

The tool perform the following steps:

1. Get Ip Address of WSL 2 machine
2. Remove previous port forwarding rules
3. Add port Forwarding rules
4. Remove previously added firewall rules
5. Add new Firewall Rules

Some of the steps require an elevated (with administrator rights) terminal window to work. The script will automatically prompt the user to open an elevated PowerShell window if the current one isn't elevated.

## How to set it up:

Before we start, note that **you need to be using WSL2 for this script to work**. I am unsure whether this will work on WSL 1 or if WSL 1 even needs this at all since I believe it shares its same network adapter with the host machine. You can learn more about the differences between WSL 1 & 2 [here](https://docs.microsoft.com/en-us/windows/wsl/compare-versions).

Also, I recommend using the cross-platform [PowerShell 7](https://docs.microsoft.com/en-us/powershell/scripting/whats-new/what-s-new-in-powershell-70?view=powershell-7.1).

1. [Install a WSL 2 distro](https://docs.microsoft.com/en-us/windows/wsl/install-win10) and make sure it's ready to go.

2. Make sure you have the `net-tools` package installed in your default WSL.

   - Try running `sudo apt install net-tools` if you don't have it installed already.

3. Download the latest [wslbridge.ps1](https://github.com/rogvc/wslbridge/releases/tag/v0.1) file somewhere in your computer.

   - I recommend saving it in `C:\Users\{YOUR_USER}\.wslconfig` or somewhere you usually have your development tools installed.

4. [Add the script to your PATH](https://medium.com/@kevinmarkvi/how-to-add-executables-to-your-path-in-windows-5ffa4ce61a53#:~:text=May%2025%2C%202016%20%C2%B7%202%20min%20read%201,and%20add%20the%20file%20path%20to%20the%20list) for easy access.

   - This is optional, but highly recommended.

5. Now you should be ready to call `wslbridge` in any **PowerShell** terminal window!

## Limitations

- Although the script attempts to port all `UDP` and `TCP` connections between host and WSL, I have only tested it with `TCP`
- Changes are not persistent, so you will need to run this script every time your computer boots, or as needed by your applications.
- The script cannot revert the changes it makes. If I have time, I plan on implementing that.
