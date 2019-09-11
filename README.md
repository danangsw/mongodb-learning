# mongodb-learning

The basic tutorial of learning mongodb with node.js and express.

## Introduction

[MongoDB](https://www.mongodb.com/) is a open-source and free NO-SQL document database used commonly in the modern web applications.

[In this tutorial](https://www.digitalocean.com/community/tutorials/how-to-install-mongodb-on-ubuntu-18-04) you will install MongoDB, manage its service and optionally remote access.

First, we need to set up the Ubuntu 18.04 server by [following this tutorial](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-18-04).

## Step 1 - Installing MongoDB

Update the package list the have the most recent version of the repository listing:
```bash
$ sudo apt update  && sudo apt upgrage
```

[`update`](https://explainshell.com/explain?cmd=apt-get+update+%26%26+apt-get+upgrade) is used to resynchronize the package index files from their sources.

[`upgrade`](https://explainshell.com/explain?cmd=apt-get+update+%26%26+apt-get+upgrade) is used to install the newest versions of all packages currently installed on the system.

Install the mongodb package:

```bash
$ sudo apt install -y mongodb
```

### Step 2 - Checking the Service and Database

Check the service status:

```bash
$ sudo systemctl status mongodb
```

The output will be:

```bash
● mongodb.service - An object/document-oriented database
   Loaded: loaded (/lib/systemd/system/mongodb.service; enabled; vendor preset: enabled)
   Active: active (running) since Tue 2019-09-10 09:26:35 WIB; 1h 18min ago
     Docs: man:mongod(1)
 Main PID: 1247 (mongod)
    Tasks: 25 (limit: 2332)
   CGroup: /system.slice/mongodb.service
           └─1247 /usr/bin/mongod --unixSocketPrefix=/run/mongodb --config /etc/mongodb.conf

Sep 10 09:26:35 ubuntu-vbox systemd[1]: Started An object/document-oriented database.
```

Verify by actually connecting to the database server and executing a diagnostic command:

```bash
$ mongo --eval 'db.runCommand({connectionStatus: 1})'
```

You will see the output of the current database version, the server address and port, and the status command:

```bash
MongoDB shell version v3.6.3
connecting to: mongodb://127.0.0.1:27017
MongoDB server version: 3.6.3
{
        "authInfo" : {
                "authenticatedUsers" : [ ],
                "authenticatedUserRoles" : [ ]
        },
        "ok" : 1
}
```

Step 3 - Managing the MongoDB Service

To verify the service status:

```bash
$ sudo systemctl status mongodb
```

To stop the service:

```bash
$ sudo systemctl stop mongodb
```

To start the service:

```bash
$ sudo systemctl start mongodb
```

To restart the service:

```bash
$ sudo systemctl restart mongodb
```

By default, MongoDB is starting automatically with the server. To Disable the automatic startup:

```bash
$ sudo systemctl disable mongodb
```

To enable it again:

```bash
$ sudo systemctl enable mongodb
```

## Adjusting the Firewall

To allow access to MongoDB on its default port `27017` from anywhere:

```bash
$ sudo ufw allow 27017
```

However, enabling internet access to MongoDB server on a default installation gives anyone unrestricted access to the database server and its data.

To allow access to MongoDB default port while specifiying the other IP Address, change `192.168.43.123/32` with your targeted IP address:

```bash
$ sudo ufw allow from 192.168.43.123/32 to any port 27017
```

To delete the rule:

```bash
$ sudo ufw delete allow to any port 27017 from 192.168.43.123/32
```

Verify the status:

```bash
$ sudo ufw status
```

[In this tutorial](https://www.howtoforge.com/tutorial/ufw-uncomplicated-firewall-on-ubuntu-15-04/) you will manage an iptables based firewall using UFW or Uncomplicated Firewall on Ubuntu.

Even though the port is open, MongoDB is currently only listening on the local address 127.0.0.1. To allow remote connections, add your server's publicly-routable IP address to `mongodb.conf` file:

```bash
$ sudo nano /etc/mongodb.conf
```

```bash

Update the following value:

...

#192.168.43.32 is mongo host address
bind_ip = 127.0.0.1,192.168.43.32
port = 27017

...
```

Save the file, exit the editor and restart mongodb:

```bash
$ sudo systemctl restart mongodb 
```

From now, your MongoDB is listening for remote connections, but anyone can access it.

## Securing MongoDB

Previously, we already create rule on `ufw` to limiting the connection, however, authentication is still disabled by default, so any users on the local system have complete access to the database. To secure this we will create an administrative user, enable authentication and test it.

### Adding and Administrative User

First, connect to Mongo shell:

```bash
$ mongo
```

The output when we use the Mongo shell warns us that access control is not enabled for the database and that read/write access to data and configuration is unrestricted.

```bash
MongoDB shell version v3.6.3
connecting to: mongodb://127.0.0.1:27017
MongoDB server version: 3.6.3
Server has startup warnings:
2019-09-10T11:56:40.214+0700 I STORAGE  [initandlisten]
2019-09-10T11:56:40.214+0700 I STORAGE  [initandlisten] ** WARNING: Using the XFS filesystem is strongly recommended with the WiredTiger storage engine
2019-09-10T11:56:40.214+0700 I STORAGE  [initandlisten] **          See http://dochub.mongodb.org/core/prodnotes-filesystem
2019-09-10T11:56:40.998+0700 I CONTROL  [initandlisten]
2019-09-10T11:56:40.998+0700 I CONTROL  [initandlisten] ** WARNING: Access control is not enabled for the database.
2019-09-10T11:56:40.998+0700 I CONTROL  [initandlisten] **          Read and write access to data and configuration is unrestricted.
2019-09-10T11:56:40.998+0700 I CONTROL  [initandlisten]
>
```

Set the username and pick the secure password:

```bash
> use admin
switched to db admin
> db.createUser({
... user: '<your administrator username>',
... pwd: '<your administrator super secret password>',
... roles: [{ role: 'userAdminAnyDatabase', db: 'admin' }]
... })
Successfully added user: {
        "user" : "<your administrator username>",
        "roles" : [
                {
                        "role" : "userAdminAnyDatabase",
                        "db" : "admin"
                }
        ]
}
>
```

Type `exit` and press `ENTER` or use `CTRL+C` to leave the Mongo shell. 

At this point, our user will be allowed to enter credentials, but they will not be required to do so until we enable authentication and restart the MongoDB daemon. 

### Enabling the Authentication

Let's open the mongo configuration file:

```bash
$ sudo nano /etc/mongodb.conf
```

Enable the auth in the security section:

```bash
...
# Turn on/off security.  Off is currently the default
#noauth = true
auth = true
...
```

Save the file, exit the editor and restart mongodb:

```bash
$ sudo systemctl restart mongodb 
```

Let's verify the service is up:
```bash
$ sudo systemctl restart mongodb
```

Make sure the output will have as following text:
```bash
● mongodb.service - An object/document-oriented database
   Loaded: loaded (/lib/systemd/system/mongodb.service; enabled; vendor preset: enabled)
   Active: active (running) since Tue 2019-09-10 12:04:20 WIB; 1min 19s ago
```

### Verify that Unauthenticated Users are Restricted

Let's connect without credentials:
```bash
$ mongo
```

You will see that warning about authentication has been resolved:
```bash
MongoDB shell version v3.6.3
```

We will be prompted for the password.

```bash
MongoDB shell version v3.6.3
Enter password:
connecting to: mongodb://127.0.0.1:27017
MongoDB server version: 3.6.3
```

See the available databases:

```bash
> show dbs
admin      0.000GB
config     0.000GB
local      0.000GB
sample     0.000GB
sharkinfo  0.000GB
test       0.000GB
```

Type `exit` or press `CTRL+C` to exit.

## Using GUI for MongoDB Client

[MongoDB Compass](https://docs.mongodb.com/compass/current/) is the GUI for MongoDB.

[The following tutorial](https://docs.mongodb.com/manual/tutorial/getting-started/) uses MongoDB Compass to connect to insert data and perform query operations.

## Tips:
**1. Your admin user not authorized, after enable `auth=on` mongodb configuration file.**

For the first time you create you user admin:

```bash
use admin
db.createUser(
  {
    user: 'admin',
    pwd: 'password',
    roles: [ { role: 'root', db: 'admin' } ]
  }
);
exit;
```

If you have already created the `admin` user, you can change the role like:

```bash
use admin;
db.grantRolesToUser('admin',
    [{ 
        role: 'root',
        db: 'admin' 
     }]
);
exit;
```
