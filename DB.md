# Database

Sources:
  - https://dzone.com/articles/establish-a-secure-ssl-connection-to-postgresql-db

### Prerequisites

1. Create Ubuntu 18.04 Bionic server

2. Initial server setup:

```
ansible-playbook -u root -v -l web-servers playbooks/setup-db.yml -D
```

3. Configuring UFW

```
sudo ufw allow from 46.101.155.23 to any port 5432
```

### Step 1 — Installing PostgreSQL

```
sudo apt update
sudo apt install postgresql postgresql-contrib
```

### Step 2 — Configuring Remote Connections

Adding a User and Database

```
sudo -i -u postgres psql
```

Once logged in:

```
create database apxr_io_prod;
create user apxr_io with encrypted password 'password';
grant all privileges on database apxr_io_prod to apxr_io;
```

Now, that we've created a user and database, we'll exit the monitor

```
\q
```

After pressing ENTER, we'll be at the command prompt and ready to continue.

### Step 3 - Configuring the Listening Address

Set the listen address in the postgresql.conf file:

```
sudo vim /etc/postgresql/10/main/postgresql.conf
```

Find the listen_addresses line and below it, define your listen addresses, being sure to substitute the hostname or IP address of your database host. You may want to double-check that you're using the public or private IP of the database server, not the connecting client:

```
listen_addresses = 'localhost, 10.21.127.157'
```

### Step 4 — Restarting PostgreSQL

```
sudo systemctl restart postgresql
```

Since systemctl doesn't provide feedback, we'll check the status to make sure the daemon restarted successfully:

```
sudo systemctl status postgresql
```

If the output contains "Active: active" then the PostgreSQL daemon is running.

### Step 5 - SSL

You need to add the following three files to the

```
/var/lib/postgresql/10/main
```

server directory 

- server.key – private key.
- server.crt – server certificate.
- root.crt – trusted root certificate.

Let’s create the first file — private key:

```
openssl genrsa -des3 -out /var/lib/postgresql/10/main/server.key 1024
```

During the server.key generation, you’ll be asked for a passphrase — specify any and confirm it to finish creation.

Now, in order to work with this key further, it’s required remove the passphrase you’ve added previously. Execute the following command for this:

```
openssl rsa -in /var/lib/postgresql/10/main/server.key -out /var/lib/postgresql/10/main/server.key
```

Set the appropriate permission and ownership rights for your private key file with the next commands:

```
chmod 400 /var/lib/postgresql/10/main/server.key
chown postgres.postgres /var/lib/postgresql/10/main/server.key
```

Create server certificate based on your server.key file

```
openssl req -new -key /var/lib/postgresql/10/main/server.key -days 3650 -out /var/lib/postgresql/10/main/server.crt -x509 -subj '/C=FR/ST=Paris/L=Paris/O=APXR/CN=approximatereality.com/emailAddress=approximatereality@gmail.com'
```

Since we are going to sign certs by ourselves, the generated server certificate can be used as a trusted root certificate as well, so just make its copy with the appropriate name:

```
cp /var/lib/postgresql/10/main/server.crt /var/lib/postgresql/10/main/root.crt
```

Open the pg_hba.conf file:

```
sudo vim /etc/postgresql/10/main/pg_hba.conf
```

Add/replace with the following

```
hostssl apxr_io_prod    apxr_io         0.0.0.0/0               md5 clientcert=1
```

To finish configurations, you need to apply some more changes to the postgresql.conf file. 

Navigate to its Security and Authentication section (approximately at the 80th line) and activate SSL usage itself, through uncommenting the same-named setting and changing its value to “on”. Also, add the new ssl_ca_file parameter below:

```
ssl = on
ssl_ca_file = '/var/lib/postgresql/10/main/root.crt'
```

Lastly, restart PostgreSQL in order to apply new settings.

```
sudo systemctl restart postgresql
sudo systemctl status postgresql
```

And exit the server.

---

Now, let’s create one more set of SSL certificate files for client instance, in order to support secure connection on both sides.

1. Generate a private key for client (also without a passphrase, just as it was done in the previous section):

```
openssl genrsa -des3 -out postgresql.key 1024
openssl rsa -in postgresql.key -out postgresql.key
```

2. Next, create SSL certificate for your PostgreSQL database user (apxr_io by default) and sign it with our trusted root.crt file on server.

```
openssl req -new -key postgresql.key -out postgresql.csr -subj '/C=FR/ST=Paris/L=Paris/O=APXR/CN=apxr_io'
openssl x509 -req -in postgresql.csr -days 365 -CA apxr-io-db1_root.crt -CAkey apxr-io-db1_server.key -out postgresql.crt -CAcreateserial
```

Note: 

The Common Name (/CN=) must be equal to database user name you’ve set during the first certificate generation in server configuration file (apxr_io in our case)

3. The postgresql.key, postgresql.crt, apxr-io-db1_root.crt files are now now ready for use by the client