# ELEC241-J P1 files

## Instructions

* Make sure before deploying the design onto the board
the DIP switch nearest to the Texas Instruments logo is in the '1' position!
* After deploying you may now flick it back to the '0' position.
* This switch, SW[3], is the global reset switch for all the components,
so it is important to have them start from a known (reset) state.

## Evidences

* all evidences are located within the OneNote
* the link to the OneNote can be found in the 'group.docx' file
* the evidences are located in the "Evidences" section of the OneNote

## Reset switch, SW[3], interrupt

* during execution of main program, the user may assert the reset signal
by toggling the switch to the '1' position at any time
* this will interrupt the main program and calibrate everything back to reset state!
