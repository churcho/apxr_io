# Nginx

Sources:
  - https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-18-04
  - https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-18-04
  - https://www.digitalocean.com/community/tutorials/how-to-set-up-nginx-with-http-2-support-on-ubuntu-18-04

## Inital setup

### Prerequisites

1. Create Ubuntu 18.04 Bionic server

2. Initial server setup:

```
ansible-playbook -u root -v -l nginx-servers playbooks/setup-nginx.yml -D
```

### Step 1 — Installing Nginx

```
sudo apt update
sudo apt install nginx
```

### Step 2 — Configuring UFW

First, open this file:

```
sudo vim /etc/default/ufw
```

And make sure the value of IPV6 is yes.

```
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22
sudo ufw allow 'Nginx HTTP'
sudo ufw enable
sudo ufw status verbose
```

### Step 3 – Checking your Web Server

At the end of the installation process, Ubuntu 18.04 starts Nginx. The web server should already be up and running.

We can check with the systemd init system to make sure the service is running by typing:

```
systemctl status nginx
```

### Step 4 – Setting Up Server Blocks

Create the directory for approximatereality.com as follows, using the -p flag to create any necessary parent directories:

```
sudo mkdir -p /var/www/approximatereality.com/html
```

Next, assign ownership of the directory with the $USER environment variable:

```
sudo chown -R $USER:$USER /var/www/approximatereality.com/html
```

The permissions of your web roots should be correct if you haven't modified your umask value, but you can make sure by typing:

```
sudo chmod -R 755 /var/www/approximatereality.com
```

Next, create a sample index.html page using vim:

```
vim /var/www/approximatereality.com/html/index.html
```

Inside, add the following sample HTML:

```
<html>
    <head>
        <title>ApproximateReality</title>
    </head>
    <body>
      <p>Something is not right.</p>
    </body>
</html>
```

Save and close the file when you are finished.

In order for Nginx to serve this content, it's necessary to create a server block with the correct directives. Instead of modifying the default configuration file directly, let’s make a new one at /etc/nginx/sites-available/approximatereality.com:

```
sudo vim /etc/nginx/sites-available/approximatereality.com
```

Paste in the following configuration block, which is similar to the default, but updated for our new directory and domain name:

```
server {
        listen 80;
        listen [::]:80;

        root /var/www/approximatereality.com/html;
        index index.html index.htm index.nginx-debian.html;

        server_name approximatereality.com www.approximatereality.com;

        location / {
                try_files $uri $uri/ =404;
        }
}
```

Notice that we’ve updated the root configuration to our new directory, and the server_name to our domain name.

Next, let's enable the file by creating a link from it to the sites-enabled directory, which Nginx reads from during startup:

```
sudo ln -s /etc/nginx/sites-available/approximatereality.com /etc/nginx/sites-enabled/
```

Two server blocks are now enabled and configured to respond to requests based on their listen and server_name directives (you can read more about how Nginx processes these directives here):

- approximatereality.com: Will respond to requests for approximatereality.com and www.approximatereality.com
- default: Will respond to any requests on port 80 that do not match the other two blocks.

To avoid a possible hash bucket memory problem that can arise from adding additional server names, it is necessary to adjust a single value in the /etc/nginx/nginx.conf file. Open the file:

```
sudo vim /etc/nginx/nginx.conf
```

Find the server_names_hash_bucket_size directive and remove the # symbol to uncomment the line:

```
...
http {
    ...
    server_names_hash_bucket_size 64;
    ...
}
...
```

Save and close the file.

Next, test to make sure that there are no syntax errors in any of your Nginx files:

```
sudo nginx -t
```

If there aren't any problems, restart Nginx to enable your changes:

```
sudo systemctl restart nginx
```

### Step 5 – Important Nginx Files and Directories

Content
- /var/www/html: The actual web content, which by default only consists of the default Nginx page you saw earlier, is served out of the /var/www/html directory. This can be changed by altering Nginx configuration files.

Server Configuration
- /etc/nginx: The Nginx configuration directory. All of the Nginx configuration files reside here.
- /etc/nginx/nginx.conf: The main Nginx configuration file. This can be modified to make changes to the Nginx global configuration.
- /etc/nginx/sites-available/: The directory where per-site server blocks can be stored. Nginx will not use the configuration files found in this directory unless they are linked to the sites-enabled directory. Typically, all server block configuration is done in this directory, and then enabled by linking to the other directory.
- /etc/nginx/sites-enabled/: The directory where enabled per-site server blocks are stored. Typically, these are created by linking to configuration files found in the sites-available directory.
- /etc/nginx/snippets: This directory contains configuration fragments that can be included elsewhere in the Nginx configuration. Potentially repeatable configuration segments are good candidates for refactoring into snippets.

Server Logs
- /var/log/nginx/access.log: Every request to your web server is recorded in this log file unless Nginx is configured to do otherwise.
- /var/log/nginx/error.log: Any Nginx errors will be recorded in this log.

## Let's Encrypt

### Step 1 — Installing Certbot

Certbot is in active development, so the Certbot packages provided by Ubuntu tend to be outdated. However, the Certbot developers maintain a Ubuntu software repository with up-to-date versions, so we'll use that repository instead.

First, add the repository:

```
sudo add-apt-repository ppa:certbot/certbot
```

Install Certbot's Nginx package with apt:

```
sudo apt install python-certbot-nginx
```

Certbot is now ready to use, but in order for it to configure SSL for Nginx, we need to verify some of Nginx's configuration.

### Step 2 — Confirming Nginx's Configuration

Certbot needs to be able to find the correct server block in your Nginx configuration for it to be able to automatically configure SSL. Specifically, it does this by looking for a server_name directive that matches the domain you request a certificate for.

To check, open the server block file:

```
sudo vim /etc/nginx/sites-available/approximatereality.com
```

Find the existing server_name line. It should look like this:

```
...
server_name approximatereality.com www.approximatereality.com;
...
```

If it does, exit your editor and move on to the next step.

If it doesn't, update it to match. Then save the file, quit your editor, and verify the syntax of your configuration edits:

```
sudo nginx -t
```

If you get an error, reopen the server block file and check for any typos or missing characters. Once your configuration file's syntax is correct, reload Nginx to load the new configuration:

```
sudo systemctl reload nginx
```

Certbot can now find the correct server block and update it.

Next, let's update the firewall to allow HTTPS traffic.

### Step 3 — Allowing HTTPS Through the Firewall

To additionally let in HTTPS traffic, allow the Nginx Full profile and delete the redundant Nginx HTTP profile allowance:

```
sudo ufw allow 'Nginx Full'
sudo ufw delete allow 'Nginx HTTP'
```

Verify:

```
sudo ufw status
```

### Step 4 — Obtaining an SSL Certificate

Certbot provides a variety of ways to obtain SSL certificates through plugins. The Nginx plugin will take care of reconfiguring Nginx and reloading the config whenever necessary. To use this plugin, type the following:

```
sudo certbot --nginx -d approximatereality.com -d www.approximatereality.com
```

This runs certbot with the --nginx plugin, using -d to specify the names we'd like the certificate to be valid for.

Follow the instructions, selecting to redirectd to hhtps, and Nginx will reload to pick up the new settings. certbot will wrap up with a message telling you the process was successful and where your certificates are stored.

Try reloading the website using https:// and notice your browser's security indicator. It should indicate that the site is properly secured, usually with a green lock icon. You can test the server using the SSL Labs Server Test, you should get an A grade.

### Step 5 — Verifying Certbot Auto-Renewal

Let's Encrypt's certificates are only valid for ninety days. This is to encourage users to automate their certificate renewal process. The certbot package we installed takes care of this for us by adding a renew script to /etc/cron.d. This script runs twice a day and will automatically renew any certificate that's within thirty days of expiration.

To test the renewal process, you can do a dry run with certbot:

```
sudo certbot renew --dry-run
```

If you see no errors, you're all set. When necessary, Certbot will renew your certificates and reload Nginx to pick up the changes. If the automated renewal process ever fails, Let’s Encrypt will send a message to the email you specified, warning you when your certificate is about to expire.

## Hardening Nginx

By default, Nginx shows its name and version in the HTTP headers.

We'll hide this information by opening Nginx's main configuration file /etc/nginx/nginx.conf

```
sudo vim /etc/nginx/nginx.conf
```

Inside the http configuration part add the line server_tokens off:

```
http {

        ##
        # Basic Settings
        ##
        server_tokens off;
...
```

After that, save and exit the file, and reload Nginx for the change to take effect:

```
sudo service nginx reload
```

## Nginx with HTTP/2

### Step 1 — Enabling HTTP/2 Support

```
sudo vim /etc/nginx/sites-available/approximatereality.com
```

In the file, locate the listen variables associated with port 443:

```
...
    listen [::]:443 ssl ipv6only=on;
    listen 443 ssl;
...
```

The first one is for IPv6 connections. The second one is for all IPv4 connections. We will enable HTTP/2 for both.

Modify each listen directive to include http2:

```
...
    listen [::]:443 ssl http2 ipv6only=on; 
    listen 443 ssl http2; 
...
```

this tells Nginx to use HTTP/2 with supported browsers.

Save the configuration file and edit the text editor.

Check the configuration for syntax errors:

```
sudo nginx -t
```

### Step 2 — Removing Old and Insecure Cipher Suites

Open the server block configuration file for your domain:

```
sudo vim /etc/nginx/sites-available/approximatereality.com
```

Locate the line that includes the options-ssl-nginx.conf file and comment it out:

```
 # include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot<^>
```

Below that line, add this line to define the allowed ciphers:

```
ssl_ciphers EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
```

Save the file and exit the editor.

Once again, check the configuration for syntax errors:

```
sudo nginx -t
```

If you see any errors, address them and test again.

Once you see no syntax errors, restart Nginx:

```
sudo systemctl reload nginx
```

At this point, you're ready to serve content through the HTTP/2 protocol. Let's improve security and performance by enabling HSTS.

### Step 4 — Enabling HTTP Strict Transport Security (HSTS)

Open the Nginx configuration file in your editor:

```
sudo vim /etc/nginx/nginx.conf
```

Add this line to the file to enable HSTS:

```
http {
...
    ##
    # Virtual Host Configs
    ##

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
    add_header Strict-Transport-Security "max-age=15768000" always;
}
...
```

By default, this header is not added to subdomain requests. If you have subdomains and want HSTS to apply to all of them, you should add the includeSubDomains variable at the end of the line, like this:

```
add_header Strict-Transport-Security "max-age=15768000; includeSubDomains" always;
```

Save the file, and exit the editor.

Once again, check the configuration for syntax errors:

```
sudo nginx -t
```

Finally, restart the Nginx server to apply the changes.

```
sudo systemctl reload nginx
```

Please visit Qualys SSL Lab and run a test against your server. If everything is configured properly, you should get an A+ mark for security.

## Reverse Proxy

Open the server block's configuration file for editing:

```
sudo vim /etc/nginx/sites-available/approximatereality.com
```

Find the following code block:

```
...
  location / {
    try_files $uri $uri/ =404;
  }
...
```

Replace the previous location block with the following:


```
    location / {
      # Proxy Headers
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
    
      # WebSockets
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
    
      proxy_pass https://127.0.0.1:4001;
    }

```

Save and close the file to continue.

Now, verify the new Nginx configuration.

```
sudo nginx -t
```

Nginx should report that the syntax is okay and that the test was successful. If not, follow the on-screen messages to resolve the problem.

Restart Nginx to propagate the changes.

```
sudo systemctl restart nginx
```

Done!