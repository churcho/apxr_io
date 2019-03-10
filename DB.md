# Database

Sources:
  - https://dzone.com/articles/establish-a-secure-ssl-connection-to-postgresql-db

### Prerequisites

1. Create Ubuntu 18.04 Bionic server

2. Initial server setup:

```
ansible-playbook -u root -v -l db-servers playbooks/setup-db.yml -D
```

3. Configuring UFW

First, open this file:

```
sudo vim /etc/default/ufw
```

And make sure the value of IPV6 is yes.

Then set the following:

```
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22
sudo ufw allow from public-ip to any port 5432
sudo ufw allow from private-ip to any port 5432
sudo ufw enable
sudo ufw status verbose
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
alter user apxr_io with superuser;
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
listen_addresses = 'localhost, public-ip, private-ip'
```

### Step 4 — Restarting PostgreSQL

```
sudo systemctl restart postgresql@10-main
```

Since systemctl doesn't provide feedback, we'll check the status to make sure the daemon restarted successfully:

```
sudo systemctl status postgresql@10-main
```

If the output contains "Active: active (running)" then the PostgreSQL daemon is running.

### Step 5 - SSL

You need to add the following three files to the

```
/var/lib/postgresql/10/main
```

server directory 

- key.pem – private key.
- cert.pem – server certificate.
- root.pem – trusted root certificate.

Let’s create the first file — private key:

```
sudo openssl genrsa -out /var/lib/postgresql/10/main/key.pem 1024
```

Set the appropriate permission and ownership rights for your private key:

```
sudo chmod 400 /var/lib/postgresql/10/main/key.pem
sudo chown postgres:postgres /var/lib/postgresql/10/main/key.pem
```

Create server certificate based on your key.pem file

```
sudo openssl req -new -key /var/lib/postgresql/10/main/key.pem -days 3650 -out /var/lib/postgresql/10/main/cert.pem -x509 -subj '/C=FR/ST=Paris/L=Paris/O=APXR/CN=approximatereality.com/emailAddress=approximatereality@gmail.com'
```

Since we are going to sign certs by ourselves, the generated server certificate can be used as a trusted root certificate as well, so just make its copy with the appropriate name:

```
sudo cp /var/lib/postgresql/10/main/cert.pem /var/lib/postgresql/10/main/root.pem
```

Open the pg_hba.conf file:

```
sudo vim /etc/postgresql/10/main/pg_hba.conf
```

Add the following

```
hostssl all             apxr_io         public-ip/32          md5 clientcert=1
hostssl all             apxr_io         private-ip/32          md5 clientcert=1
```

To finish configurations, you need to apply some more changes to the postgresql.conf file. 

```
sudo vim /etc/postgresql/10/main/postgresql.conf
```

Navigate to its Security and Authentication section (approximately at the 80th line) and activate SSL usage itself, through uncommenting the same-named setting and changing its value to “on”. Also, add the new ssl_ca_file parameter below:

```
ssl = on
ssl_ca_file = '/var/lib/postgresql/10/main/root.pem'
```

Lastly, restart PostgreSQL in order to apply new settings.

```
sudo systemctl restart postgresql@10-main
sudo systemctl status postgresql@10-main
```

Copy the root.pem and key.pem files to your local machine as you will need them in the next step.

```
sudo cat '/var/lib/postgresql/10/main/key.pem'
sudo cat '/var/lib/postgresql/10/main/root.pem'
```

Place them under (temporarily) under priv/cert/prod/ e.g. db_server.pem and db_root.pem

Exit the server.

---

Now, on your local machine, in the priv/cert/prod/ directory let’s create one more set of SSL certificate files for client instance, in order to support secure connection on both sides.

1. Generate a private key for the client:

```
openssl genrsa -out db_key.pem 1024
```

2. Next, create SSL certificate for your PostgreSQL database user and sign it with our trusted root.pem file on server.

```
openssl req -new -key db_key.pem -out cert.csr -subj '/C=FR/ST=Paris/L=Paris/O=APXR/CN=approximatereality.com'
openssl x509 -req -in cert.csr -days 365 -CA db_root.pem -CAkey db_server.pem -out db_cert.pem -CAcreateserial
```

The Common Name (/CN=) must be equal to database user name you’ve set during the first certificate generation in server configuration file

3. The db_key.pem, db_cert.pem, db_root.pem files are now now ready for use by the client.

### Step 6 - Log management

```
sudo vim /etc/systemd/journald.conf
```

```
[Journal]
Storage=persistent
Compress=yes
Seal=yes

SystemMaxUse=10%
SystemKeepFree=15%

MaxRetentionSec=1month
MaxFileSec=1month
```

```
sudo systemctl restart systemd-journald
sudo systemctl restart postgresql@10-main
```

Verify:

```
sudo journalctl -f -u postgresql@10-main
```

### Step 7 - DB backups

Install the necessary packages:

```
sudo apt install python-pip
sudo pip install awscli
```

Set your credentials:

```
aws configure
```

Create the backup script:

```
sudo vim backup.sh
```

```
#!/bin/bash

export PGPASSWORD=
BUCKET=apxr-io-db-backups

DB_USER=apxr_io
DB_HOST=localhost

PGSSLMODE=allow pg_dump -U $DB_USER \
                        -h $DB_HOST \
                        -p 5432 \
                        -Fc --file=postgres_db.custom apxr_io_prod

S3_KEY=$BUCKET/backups/$(date "+%Y-%m-%d")-postgres_db.custom
/usr/local/bin/aws s3 cp postgres_db.custom s3://$S3_KEY --sse AES256

rm -f postgres_db.custom
```

Set the correct permissions on the file:

```
sudo chmod +x backup.sh
```

Verify it works:

```
/home/rob/backup.sh
```

Add a cron entry:

```
crontab -e

00 00 * * * /home/rob/backup.sh
```