Prerequisite

Using the Raspberry Pi Image Victron Venus OS
Using a Pace BMS (maybe this solution hels in case of other BMS too)

Assumption:
You have a running setup of an ESS in Victron Venus OS.
Your LiFePo4 Battery is connected with a canbus to the Venus system.

This package is to solve the following problem:
The PACE-BMS send Charging Voltage Limit "CVL" and Charging Current Limit "CCL" according its fixed configuration settings.
The CVL is taken from the BMS Setting "Pack OV Alarm(V)". This leads to the behaviour that the Venus System takes this (too high) value for the charging limits. 
Reaching that limit the BMS cuts off the charging path. This leads to alarms and is certainly not as expected.

##### SETUP #####
Copy the files to the folder:
/data/virtualbms

Install the package with:
/data/virtualbms/install.sh

Rebbot the system

This package tracks the data coming on the canbus from the BMS. It replaces the CVL with the value which is set up in the config.ini file.
All packages (manipulated and original) are sent to the virtual canbus (vcan0).
The setup of the virtual canbus is also done in this package.
Similar procedure for the CCL. It replaces the CCL according the State of Charge (SoC). Both values can be set up in the config.ini
When the SoC exceeds the "SOC_DEGRADE_LIMIT" the CCL is set to the value which is set up under "UPPER_CURRENT". 
This is to give the BMS time to balance the cells. The balancing of the BMS is only active while charging. 
Limiting the current extends the charging time at the upper SoS and therewith extends the balancing time.

Changes in the config.ini are immediately prceeded! No restart is needed.

At the end you have a second BMS in the venus System. You have to activate it as the leading BMS under "Settings" - "DVCC" (all the way down).
