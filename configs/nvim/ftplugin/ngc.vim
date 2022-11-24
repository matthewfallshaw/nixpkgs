imap buffer ;gg
  \ %
  \  (Hand coded)
  \  (G Code for OpenBuilds Lead CNC 1010)
  \
  \  (Program Name : cylinder 12mm)
  \  (1 Operation :)
  \  (1 : Rotary diameter reduction)
  \  (  Work Coordinate System : G54)
  \  (  Tool : End Mill 2 Flutes, Diam = 6mm, Len = 50mm)
  \  (  Spindle : RPM = 15000, set router dial to 1)
  \
  \  G94 (units per minute)
  \  G54 (first workspace)
  \  G21 (metric)
  \  G90 (absolute mode)
  \  G4 P4 (pause 4s)
  \
  \  #10 = 10 (radius of stock)
  \  #11 = 18 (length of stock)
  \  #12 = 6  (target finished radius)
  \  #13 = 6  (diameter of tool)
  \
  \  G0 F1000 (1000mm/m rapids)
  \
  \  M3 S15000 (start spindle 15000rpm)
  \
  \  G0 F1000 X[#11 + #13/2 + 1] Y0
  \
  \  #1 = [#10]
  \  G0 F300 Z[#1 + 1]
  \
  \  O100 do
  \    G1 F300 X22 Z[#1]
  \    G10 L20 P1 A0
  \    G1 F2000 A3600 X0
  \    G0 F1000 Z[#1 + 1]
  \    G0 X[#11 + #13/2 + 1]
  \    O101 if [#1 - 1 GE #12]
  \      #1 = [#1 - 1]
  \    O101 elseif [#1 EQ #12]
  \      #1 = [#12 - 0.001]
  \    O101 else
  \      #1 = #12
  \    O101 endif
  \  O100 while [#1 GE #12]
  \
  \  G0 Z12
  \  M5
  \
  \  M2
  \  %
