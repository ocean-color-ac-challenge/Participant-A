beam-meris-ac
=============

MERIS atmospheric correction effects using BEAM - using SmacOp

### Installation 

Log on the developer sandbox and run these commands in a shell:

* Install **Java 7**

```bash
sudo yum install -y java-1.7.0-openjdk
```

* Select Java 7

```bash
sudo /usr/sbin/alternatives --config java
```
This will show on the terminal window:

```
There are 3 programs which provide 'java'.

  Selection    Command
-----------------------------------------------
 + 1           /usr/java/jdk1.6.0_35/jre/bin/java
   2           /usr/lib/jvm/jre-1.5.0-gcj/bin/java
*  3           /usr/lib/jvm/jre-1.7.0-openjdk.x86_64/bin/java

Enter to keep the current selection[+], or type selection number:
```

Select java 1.7 out of the menu options by typing the correct number (here it's *3*).

* Install this application

```bash
cd
git clone git@github.com:ocean-color-ac-challenge/beam-meris-ac.git
cd beam-meris-ac
mvn install
```

### Submitting the workflow

* Via the Sandbox shell 

Run this command in a shell:

```bash
ciop-simwf
```

* Via the Web Processing Service dashboard tab

Use your browser to go to the Sandbox dashboard tab at the address http://<sandbox ip>/dashboard

Click on the _Invoke_ tab

Below the "Process List" click on _BEAM Atmos Correction_

Fill the parameters and click submit. 


