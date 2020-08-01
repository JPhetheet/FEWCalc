# FEWCalc

![FEWCalc_logo](https://user-images.githubusercontent.com/47259270/85034602-e3270100-b147-11ea-8486-4e26997e8ae4.png)

FEWCalc is the Food-Energy-Water Calculator assembled by Jirapat Phetheet and Professor Mary C. Hill from Department of Geology, University of Kansas.

The calculation is divided into two parts. The first part is crop calculation using a crop model called Decision Support System for Agrotechnology Transfer (DSSAT) which was developed by Jones et al., 2003 from the University of Florida. The other is the FEWCalc conducted using NetLogo agent-based modeling software by Uri Wilensky, 1999.

# Instructions

NetLogo version 6.1.1, can run on almost all types of computers, as discussed on the NetLogo website. FEWCalc was developed using Microsoft Windows Windows 7 and 10, and macOS Catalina (version 10.15.5). A machine with 64 MB of memory (RAM) is recommended for Windows operating systems. For macOS users, OS X Mountain Lion 10.8.3 or newer is required with 128 MB RAM (258 MB RAM recommended).

## **Step 1. Download NetLogo**
FEWCalc is developed using a NetLogo platform as an agent-based model. NetLogo is an open source software which is available at https://ccl.northwestern.edu/netlogo. A screenshot of this site is shown in **Fig. 1.** Click “Download NetLogo”. Download NetLogo version 6.1.1 or higher. The download can be placed in any directory on your computer.

<img width="468" alt="Fig1" src="https://user-images.githubusercontent.com/47259270/89093918-9e4de580-d3e8-11ea-9bf0-b6a72422b786.png">

**Fig. 1.** NetLogo web site.

## **Step 2. Get FEWCalc From GitHub Repository When You Have NO GitHub Account**
[See Step 7 if you DO have a GitHub account]

Go to https://github.com/JPhetheet/FEWCalc. You will see the image in **Fig. 2.** This FEWCalc repository includes a Netlogo file and its supporting documents such as input files and figures used in FEWCalc. Click “Clone or Download” in the top right corner to get the dropdown menu shown in **Fig. 2.** 

Click “Download ZIP” to download FEWCalc. A folder “FEWCalc-master” is saved in a local directory that you choose. Navigate to that directory and unzip the downloaded zip file. Do this by right clicking on the zip file and selecting one of the download options. The exact options available will depend on your computer and available utilities. The FEWCalc directory is shown in **Fig. 3.**

<img width="470" alt="Fig2" src="https://user-images.githubusercontent.com/47259270/89093989-a3f7fb00-d3e9-11ea-9209-06a4748bf7e7.png">

**Fig. 2.** FEWCalc repository.

<img width="470" alt="Fig3" src="https://user-images.githubusercontent.com/47259270/89094018-f6d1b280-d3e9-11ea-96e0-5f65d6f80c80.png">

**Fig. 3.** A FEWCalc-master folder downloaded from FEWCalc GitHub repository.

## **Step 3. Launch FEWCalc**
Click or double click (depending on how your computer is set up) “FEWCalc.nlogo” file from FEWCalc-master folder (**Fig. 3**). You will see the image in **Fig. 4** with the square in the middle will be blank.

<img width="470" alt="Fig4" src="https://user-images.githubusercontent.com/47259270/89094063-824b4380-d3ea-11ea-9aff-29139329ed91.png">

**Fig. 4.** FEWCalc interface before setting model’s parameters.

## **Step 4. SetUp FEWCalc**
Click “SetUp” on the top left to get the image in **Fig. 5.**

<img width="470" alt="Fig5" src="https://user-images.githubusercontent.com/47259270/89094130-12898880-d3eb-11ea-9cff-1fecb38bdfa9.png">

**Fig. 5.** FEWCalc interface. 

The user-defined inputs are controlled by the features on the left side of the image shown in **Fig. 5.** This part of the image with the default values defined when FEWCalc is started using the distributed FEWCalc.nlogo file is shown in **Fig. 6.** All features are defined in **Table 1.**

<img width="335" alt="Fig6" src="https://user-images.githubusercontent.com/47259270/89094183-5b414180-d3eb-11ea-8060-5fc04618fd3e.png">

**Fig. 6.** FEWCalc user inputs showing default values defined by clicking “Set up” when the unchanged distributed file FEWCalc.nlogo is used. 

**Table 1.** FEWCalc user-input features, descriptions, default values imposed each time FEWCalc is started, and the units of those values. Default values are discussed in Appendix A and the main article.

<img width="727" alt="Table 1" src="https://user-images.githubusercontent.com/47259270/89095145-0efaff00-d3f5-11ea-9b6e-b66e7793ee00.png">

## **Step 5. Run FEWCalc**
If any inputs are changed, click “Setup” again before running the program.
Run the program by doing one of the following. 

* Click “Go once” to advance the simulation one time step. User inputs can be changed each step of the simulation.
* Or click “Go” to run the entire simulation period. The same user inputs are used throughout the simulation 

When the simulation is completed using the default values, FEWCalc will look like **Fig. 7.** The defaults provide results for creating the last 50 years of the simulation by repeating the first 10 historical years five times. Additional future scenarios can be simulated using the “Future Process” drop down menu under “Climate Scenario” section of the input panel.

<img width="470" alt="Fig7" src="https://user-images.githubusercontent.com/47259270/89095219-ecb5b100-d3f5-11ea-84ca-3ec885551350.png">

**Fig. 7.** FEWCalc interface after running the entire defined simulation time of 60 years (top left). This can be accomplished by clicking on “Go Once” 60 times, or “Go” once (top left).

Annotated images of the central area, which is called the World are shown in **Fig. 8.** 



**Fig. 8** (a) FEWCalc interface and (b) a list of graphical components within the World.

To obtain the results shown in the article for which this section in an appendix, add a Production Tax Credit (PTC) of 30% and rerun FEWCalc.

To save the input file for the altered run, click File at the top left of the NetLogo window, and click Save As. Save the file as, for example. FEWCalc-PTC.30.nlogo. If this file is clicked to start FEWCalc next time, this change will be implemented.

## **Step 6. Advanced Features of FEWCalc**

### 6.1 More Information About FEWCalc
For more information, you can click an Info tab at the top of the program **(Fig. 9).**

