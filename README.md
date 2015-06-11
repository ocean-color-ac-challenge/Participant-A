Participant-A
=============
MERIS atmospheric correction effects using BEAM - using SmacOp

### Quick link

* [Installation](#installation)
* [Submitting the workflow](#submit)
* [Test the application](#test)

### <a name="installation"></a>Installation

Log on the Developer Cloud Sandbox and run these commands in a shell:

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
git clone git@github.com:ocean-color-ac-challenge/Participant-A.git
cd beam-meris-ac
mvn install
```

### <a name="submit"></a>Submitting the workflow

* Via the Sandbox shell 

Run this command in a shell:

```bash
ciop-run
```

* Via the Web Processing Service dashboard tab

Use your browser to go to the Sandbox dashboard tab at the address http://<sandbox ip>/dashboard

Click on the _Invoke_ tab

Below the "Process List" click on _Participant A_

Fill the parameters and click submit. 

### <a name="test"></a>Test the application

##### Test Participant-A-01

* Test Procedure

Invoke the application via the Dashboard with the parameters listed in the test inputs specification

* Inputs specification 

| Parameter   | Value                                                                                                   |
|-------------|---------------------------------------------------------------------------------------------------------|
| source      | https://challenges.esa.int/eceo/datapackage/FRSPAR/description?key=495f181f-47d3-4668-b717-d36d4a560837 |
| startdate   | 2002-03-01                                                                                              |
| enddate     | 2012-10-01                                                                                              |
| aerosolType | CONTINENTAL                                                                                             |
| tauAero550  | 0.1                                                                                                     |
| useMerisADS | true                                                                                                    |
| poi         |                                                                                                         |
| window      |                                                                                                         |
| aggregation |                                                                                                         |
| publishL2   | true                                                                                                    |
| evaluate    |                                                                                                         |

* Outputs specification

| Output                                                             |
|--------------------------------------------------------------------|
| MER_FRS_1PPEPA20040711_020449_000002422028_00275_12353_1787.N1.png |
| MER_FRS_1PPEPA20040711_020449_000002422028_00275_12353_1787.N1.tgz |
| MER_FRS_1PPEPA20040717_021529_000002642028_00361_12439_1968.N1.png |
| MER_FRS_1PPEPA20040717_021529_000002642028_00361_12439_1968.N1.tgz |

* Test pass/fail criteria

All products listed in test outputs specification are generated
