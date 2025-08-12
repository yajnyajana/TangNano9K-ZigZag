ZigZag Arcade for the Tang Nano 9K FPGA Dev Board. Pinballwiz.org 2025
Code from Mister Project.

Notes:
Setup for keyboard controls - Single Player Only (5 = Coin) (Start P1 = 1) (LCtrl = Fire) (Arrow Keys = Move L or R)
Consult the Schematics Folder for Information regarding peripheral connections.

Build:
* Obtain correct roms file for ZigZag (see scripts in tools folder for rom details).
* Unzip rom files to the tools folder.
* Run the make proms script in the tools folder.
* Place the generated prom files inside the proms folder.
* Open the TangNano9k-ZigZag project file using GoWin.
* Compile the project updating filepaths to source files as necessary.
* Program Tang Nano 9K Board.
