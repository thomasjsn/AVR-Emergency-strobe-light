'--------------------------------------------------------------
'                         Thomas Jensen
'--------------------------------------------------------------
'  file: AVR_EMERGENCY v1.0
'  date: 12/08/2007
'--------------------------------------------------------------
$regfile = "attiny2313.dat"
$crystal = 8000000
Config Portd = Input
Config Portb = Output
Config Watchdog = 1024

Dim Program As Byte , A As Byte , B As Byte , C As Byte , Ext_select As Byte , Mode_select As Byte , Random As Byte
Dim Random_counter As Integer , D As Byte , Eeprom As Eram Byte
Config Timer1 = Pwm , Pwm = 8 , Prescale = 1 , Compare A Pwm = Clear Up , Compare B Pwm = Clear Up

'Out
'PB.0 : Mode 1
'PB.1 : Mode 2
'PB.3 : LEDs
'PB.5 : Mode 3
'PB.6 : Mode 4

'In
'PD.0 : Cycle trough modes
'PD.1 : Change mode
'PD.2 : Input available
'PD.3 : Pulse const.
'PD.4 : Pulse fade

Ddrb.3 = 1
Pwm1a = 255
Portb.0 = 0
Portb.1 = 0
Portb.5 = 0
Portb.6 = 0
Portb.7 = 0

'get program from eeprom
If Eeprom < 1 Or Eeprom > 4 Then Eeprom = 1
Program = Eeprom

Start Watchdog

Main:
Select Case Program

'1: fade quick - no pause
Case 1
Portb.0 = 1
Portb.1 = 0
Portb.5 = 0
Portb.6 = 0
For A = 1 To 25
   Pwm1a = Pwm1a - 10
   Gosub Switches
   Waitms 10
Next A
   For C = 1 To 2
   Waitms 10
   Gosub Switches
   Next C
For A = 1 To 25
   Pwm1a = Pwm1a + 10
   Gosub Switches
   Waitms 10
Next A
   For C = 1 To 5
   Waitms 10
   Gosub Switches
   Next C

'2: pulse x 3 - pause 300ms
Case 2
Portb.0 = 0
Portb.1 = 1
Portb.5 = 0
Portb.6 = 0
For A = 1 To 3
   Pwm1a = 0
   Waitms 10
   Gosub Switches
   Pwm1a = 255
   For C = 1 To 5
   Waitms 10
   Gosub Switches
   Next C
Next A
   For C = 1 To 30
   Waitms 10
   Gosub Switches
   Next C

'3: pulse singel - pause random ms
Case 3
Portb.0 = 0
Portb.1 = 0
Portb.5 = 1
Portb.6 = 0
   Pwm1a = 0
   Waitms 10
   Gosub Switches
   Pwm1a = 255
   Random = Rnd(30)
   For C = 1 To Random
   Waitms 10
   Gosub Switches
   Next C

'4: strobe
Case 4
Portb.0 = 0
Portb.1 = 0
Portb.5 = 0
Portb.6 = 1
   Pwm1a = 0
   For C = 1 To 2
   Waitms 10
   Gosub Switches
   Next C
   Pwm1a = 255
   For C = 1 To 5
   Waitms 10
   Gosub Switches
   Next C

End Select

Goto Main
End

'switches, mode change and random
Switches:
If Pind.2 = 0 Then Goto Ext_input
If Pind.1 = 1 Then Mode_select = 0
If Pind.1 = 0 And Mode_select = 0 Then
   Mode_select = 1
   Incr Program
   Eeprom = Program
End If
If Pind.0 = 0 Then
   Incr Random_counter
   If Random_counter > 500 Then
      Random_counter = 0
      Incr Program
   End If
End If
If Pind.0 = 1 Then Random_counter = 0

If Program > 4 Then Program = 1
Reset Watchdog

Return

'if external control enabled
Ext_input:
Portb.0 = 0
Portb.1 = 0
Portb.5 = 0
Portb.6 = 0
Portb.7 = 1
Pwm1a = 255
Do
If Pind.3 = 0 And Pwm1a = 255 Then
   Pwm1a = 0
   Ext_select = 1
   End If
If Pind.4 = 0 And Pwm1a = 255 Then
   For A = 1 To 255
   Decr Pwm1a
   Ext_select = 2
   Waitus 700
   Next A
End If

If Ext_select = 1 And Pind.3 = 1 And Pwm1a = 0 Then Pwm1a = 255
If Ext_select = 2 And Pind.4 = 1 And Pwm1a = 0 Then
   For A = 1 To 255
   Incr Pwm1a
   Waitms 1
   Next A
End If

Reset Watchdog

If Pind.2 = 0 Then
   Loop
   Else
   Pwm1a = 255
   Portb.0 = 0
   Portb.1 = 0
   Portb.5 = 0
   Portb.6 = 0
   Portb.7 = 0
   Goto Main
   End If
End