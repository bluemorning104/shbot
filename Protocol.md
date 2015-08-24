### Things that need to be implemented ###
Updating of Slave-tasks.

DDoSing support.

VPC IP displaying.

IP Reset.

Password Reset.

Group Server Managing support.


# Introduction #
This page is a quick protocol idea drafting page for shbot.


# Details #
## Requests ##
### LOGIN ###
Will accept 2 arguments, username and password. Not much to question here.
### LOGINSLAVE ###
Logs into a slave, returns true if it works
### GETSLAVES ###
Gets the slavelist page, dumps IPs off it, returns these IPs, takes no params.
### CRACKIP ###
Cracks a slave's password by IP, returns true if it works
### CLEAR\_LOGS ###
Clears a slave's logs takes IP as param, returns true if it works
### CLEAR\_LOGS\_IP ###
Clears your IP only out of a slave's logs. takes IP as param, returns true if it works
### CLEAR\_LOCAL\_LOGS ###
Clears the local logs, returns true.
### EXTRACT\_LOGS ###
Returns IPs in current machines logs, takes IP as param.
### EXTRACT\_LOGS\_BANK ###
Returns a list of bank #s from the current machines logs, machines IP as param.
### UPL\_LIST ###
Returns a list of software that could possibly be uploaded in the format id:name, comma separated.
### UPLOAD ###
Takes IP and ID provided by UPL\_LIST. Uploads a file.
### AV\_LIST ###
Lists AV scanners you can run.
### AV\_RUN ###
Takes IP and ID provided by AV\_LIST. Runs av scanner.
### VIR\_INST\_LIST ###
Lists viruses you could possibly install
### VIR\_INST ###
Takes IP and ID. Installs a virus.
### CAPRET ###
Returns the code for a send captcha

## Replies ##
### CAPTCHA ###
Rest of reply will contain the image in png format
### TIMER ###
Will pass back the amount of time to sleep for.
### RETURN ###
Passes back the data that has actually been requested, this is good. :)

# Example #
| **Client** | **Server** |
|:-----------|:-----------|
|LOGIN user password | RETURN 1   |
|GETSLAVES   | CAPTCHA _PNG IMAGE_|
|CAPRET _HUMAN READ CAPTCHA_ | RETURN 1   |
|LOGINSLAVE 1.1.1.1 | RETURN 1   |
|EXTRACT\_LOGS | RETURN  2.2.2.2 3.3.3.3|
|CRACKIP 2.2.2.2 | RETURN 1   |
|LOGINSLAVE 2.2.2.2 |RETURN 1    |}}}

```