# Goaccess

### Step 1 — Install the build-essential Package

```
sudo apt-get install build-essential
```

### Step 2 — Install GoAccess Dependencies

```
sudo apt-get install libncursesw5-dev
sudo apt-get install libgeoip-dev
```

### Step 3 — Set Up the Build Directory

The /usr/local/src directory is a suitable place to build the GoAccess software. Give your current user account ownership of this directory by running:

```
sudo chown $USER /usr/local/src
```

Then give the directory read, write, and execute permissions for this same user via the command:

```
sudo chmod u+rwx /usr/local/src
```

Change to this directory with the cd command:

```
cd /usr/local/src

wget https://tar.goaccess.io/goaccess-1.3.tar.gz
tar -xzvf goaccess-1.3.tar.gz
cd goaccess-1.3/
./configure --enable-utf8 --enable-geoip=legacy
sudo make
sudo make install
```

### Step 4 — Edit the GoAccess Config File

```
cd /
sudo cp usr/local/src/goaccess-1.3/config/goaccess.conf /usr/local/etc/goaccess.conf
sudo vim /usr/local/etc/goaccess.conf
```

Now uncomment (remove #) from these locations:

```
1. Apache/nginx time format time-format %H:%M:%S
2. Apache/nginx date format date-format %d/%b/%Y
3. NCSA Comobined log format log-format %h %^[%d:%t %^] "%r" %s %b "%R" "%u"
```

### Step 5 — Run GoAccess

```
cd /
sudo goaccess -f /var/log/nginx/access.log -a -m
```

### Step 6 — Usage

Here's how to interact with the dashboard:

- Pressing F1 or h will bring up a small help window, listing the keys and their functions found here in this section, as well as provide some other helpful information.
- 0-9 or SHIFT + 0-9 selects the respectively numbered module and sets it to active. The corresponding numbers can be seen on the dashboard for each section.
- o or ENTER is used for expanding the currently selected module on the dashboard. Modules are explained in the next section.
- j will scroll down within an expanded active module, and k will scroll back up within an expanded active module.
- s shows the sort options available for the active module.
- Finally, pressing q will quit the program or current window, or collapse an active module, depending upon your current level of depth in the dashboard.

More interaction can be achieved through the following keys:

- Pressing the TAB key on your keyboard will move forward through the modules in order.
- Pressing SHIFT + TAB together will do the opposite of the last action, and iterate backward through the modules.
- F5 can be pressed to refresh and redraw the dashboard.
- c when pressed sets and alters the current color scheme in use on the Dashboard.
- g moves the focus onto the first item and back to the top of the dashboard screen.
- G scrolls to the last item or bottom of the dashboard screen.