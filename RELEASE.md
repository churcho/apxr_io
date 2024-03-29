# Release process

Sources:
  - https://github.com/cogini/elixir-deploy-template

### Overview

We deploy Erlang "releases" using systemd for process supervision. We run in the cloud or dedicated server instances running Ubuntu Linux 18.04 Bionic. We deploy using Ansible (Automates server configuration).

1. Set up the web server
2. Set up build server
3. Build the app
4. Deploy the release

The actual work of checking out and deploying is handled by simple shell scripts which you run on the build server or from your dev machine via ssh.

### 1. Set up web server

Run the following Ansible commands from the `ansible` dir in the project.

Initial server setup, create directories, etc:

```
ansible-playbook -u root -v -l web-servers playbooks/setup-web.yml -D
```

In this command, `web-servers` is the group of servers, but you could also specify a specific host like `web-server`.

The -u flag specifies which user account to use on the server. We have to use root to do the initial bootstrap, but you should generally use your own user account, assuming it has sudo. The -v flag controls verbosity, you can add more v's to get more debug info. The -D flag shows diffs of the changes Ansible makes on the server. If you add --check to the Ansible command, it will show you the changes it is planning to do, but doesn't actually run them. These scripts are safe to run in check mode, but may give an error during the play if required OS packages are not installed.

At this point, the web server is set up, but we need to build and deploy the app.

### 2. Set up build server

This is the same as the web server.

Set up the server:

```
ansible-playbook -u root -v -l build-servers playbooks/setup-build.yml -D
```

This sets up the build environment, e.g. installing ASDF.

Log into the build machine:

```
ssh -A deploy@apxr-io
```

Check out project from git to build directory that was created at the end of the last step.

```
git clone git@github.com:Rober-t/apxr_io.git "/home/deploy/build/apxr-io"
```

### 3. Build the app

Make sure you have added the necessary environment variables:

```
cd build/apxr-io
vim "config/prod.exs"
```

Build the production release:

```
bin/build-release
```

Note: `asdf install` builds Erlang from source, so the first time it runs it can take a long time. If it fails due to a lost connection, delete /home/deploy/.asdf/installs/erlang/[version] and try again. You may want to run it under `tmux`.

### 4. Deploy the release

Whenever you change the db schema, you need to run migrations on the server.

After building the release, but before deploying the code, update the db to match the code:

```
bin/db-setup
# or
bin/db-migrate
```

Deploy the release:

```
bin/deploy-local
```

The build is done under the deploy user, who owns the files under `/srv/apxr-io`.

Verify it works

Check status:

```
sudo systemctl status apxr-io
```

Have a look at the logs:

```
journalctl -f -u apxr-io
# or
journalctl -r -u apxr-io
```

Stop:

```
sudo systemctl stop apxr-io
```

You can get a console on the running app by logging in (via ssh) as the `apxr-io` user the app runs under and executing:

```
bin/remote-console
```

### Step 5 - Log management

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
sudo systemctl restart apxr-io.service
```

Verify:

```
sudo journalctl -f -u apxr-io.service
```