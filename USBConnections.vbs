Set objFSO=CreateObject("Scripting.FileSystemObject")
' How to write 
outFile="USBConnectedItems.txt" ' Name of the text file we will use for connections
If objFSO.FileExists(sname) Then
  objFSO.DeleteFile outfile ' Delete file if it exists so we dont get dupes
End If
Set objFile = objFSO.CreateTextFile(outFile, True) 'Create new file 

On Error Resume Next
strComputer = "."
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
Set colDevices = objWMIService.ExecQuery ("Select * From Win32_USBControllerDevice")
For Each objDevice in colDevices
 strDeviceName = objDevice.Dependent
 'msgbox strDeviceName
 strQuotes = Chr(34)
 strDeviceName = Replace(strDeviceName, strQuotes, "")
 arrDeviceNames = Split(strDeviceName, "=")
 strDeviceName = arrDeviceNames(1)
 Set colUSBDevices = objWMIService.ExecQuery ("Select * From Win32_PnPEntity Where DeviceID = '" & strDeviceName & "'")
 For Each objUSBDevice in colUSBDevices
 y = objUSBDevice.Caption 
 if instr(1,y,"USB Device") then x = x & "USB Device: " & y & vbcrlf
 Next 
Next
objFile.WriteLine x
 
'Get USB details for DISKS
y=""
for i = 0 to 10
DiskIndex=i
  Set objWMIService = GetObject("winmgmts:\\" & strComputer  & "\root\cimv2")
' WMI Query to the Win32_OperatingSystem
    x = "\\\\.\\PHYSICALDRIVE" & DiskIndex  'for a query we must use \\ for a single \
    x = "Select * from Win32_DiskDrive where InterfaceType = 'USB' AND DeviceID = '" & x & "'"
    Set colItems = objWMIService.ExecQuery(x)
    For Each DD In colItems
        y = y & vbcrlf & "Device " & DiskIndex & ":" & DD.Model
        y = y & " FWARE:" & DD.FirmwareRevision
        y = y & " IFACE_TYPE:" & DD.InterfaceType  'USB
        y = y & " MEDIA_TYPE:" &  DD.MediaType
        if not IsNull(DD.Size) then y = y & " SIZE:" &  DD.size
   Next
Next
objFile.WriteLine y 
objFile.WriteLine "--------------------------------------"

'Find USB drives (or a specific drive model - in this case KINGSTON USB drives)
'If you want all USB drives listed, comment out with a ' the  If line and the End If line
strComputer = "."
TargetPath = ""
Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
Set colDiskDrives = objWMIService.ExecQuery("SELECT * FROM Win32_DiskDrive WHERE InterfaceType = 'USB'")
For Each objDrive In colDiskDrives
    'If Instr(1,ucase(objDrive.Caption), "KINGSTON") > 0 Then
 strDeviceID = Replace(objDrive.DeviceID, "\", "\\")
 Set colPartitions = objWMIService.ExecQuery ("ASSOCIATORS OF {Win32_DiskDrive.DeviceID=""" & strDeviceID & """} WHERE AssocClass = " & "Win32_DiskDriveToDiskPartition")
 For Each objPartition In colPartitions
 Set colLogicalDisks = objWMIService.ExecQuery("ASSOCIATORS OF {Win32_DiskPartition.DeviceID=""" & objPartition.DeviceID & """} WHERE AssocClass = " & "Win32_LogicalDiskToPartition")
 For Each objLogicalDisk In colLogicalDisks
 TargetPath = TargetPath & objLogicalDisk.DeviceID & vbtab
 Next
 Next
    'End If
Next
objFile.WriteLine "USB Drive(s) mounted at " & TargetPath
objFile.WriteLine "--------------------------------------"

'Show drive letters associated with each
ComputerName = "."
Set wmiServices  = GetObject ( _
    "winmgmts:{impersonationLevel=Impersonate}!//" _
    & ComputerName)
' Get physical disk drive
Set wmiDiskDrives =  wmiServices.ExecQuery ( "SELECT Caption, DeviceID FROM Win32_DiskDrive WHERE InterfaceType = 'USB'")

For Each wmiDiskDrive In wmiDiskDrives
    x = wmiDiskDrive.Caption & Vbtab & " " & wmiDiskDrive.DeviceID 

    'Use the disk drive device id to
    ' find associated partition
    query = "ASSOCIATORS OF {Win32_DiskDrive.DeviceID='" & wmiDiskDrive.DeviceID & "'} WHERE AssocClass = Win32_DiskDriveToDiskPartition"    
    Set wmiDiskPartitions = wmiServices.ExecQuery(query)

    For Each wmiDiskPartition In wmiDiskPartitions
        'Use partition device id to find logical disk
        Set wmiLogicalDisks = wmiServices.ExecQuery ("ASSOCIATORS OF {Win32_DiskPartition.DeviceID='" _
            & wmiDiskPartition.DeviceID & "'} WHERE AssocClass = Win32_LogicalDiskToPartition") 
			x = ""
        For Each wmiLogicalDisk In wmiLogicalDisks
            x = x & wmiDiskDrive.Caption & " " & wmiDiskPartition.DeviceID & " = " & wmiLogicalDisk.DeviceID
			objFile.WriteLine x 
        Next      
    Next
Next
objFile.close