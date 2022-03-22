set objFSO=CreateObject("Scripting.FileSystemObject")
' How to write 
outFile="USBConnectedItems.txt" ' Name of the text file we will use for connections
If objFSO.FileExists(sname) Then
  objFSO.DeleteFile outfile ' Delete file if it exists so we dont get dupes
End If
set objFile = objFSO.CreateTextFile(outFile, True) 'Create new file 

On Error Resume Next
strComputer = "." 'use the local comp the script is running against
set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
'Query system for all objs connected via USB
set colDevices = objWMIService.ExecQuery ("Select * From Win32_USBControllerDevice")
for each objDevice in colDevices
 strDeviceName = objDevice.Dependent
 strDeviceName = Replace(strDeviceName, Chr(34), "")
 arrDeviceNames = Split(strDeviceName, "=")
 strDeviceName = arrDeviceNames(1)
 
 set colUSBDevices = objWMIService.ExecQuery ("Select * From Win32_PnPEntity Where DeviceID = '" & strDeviceName & "'")
 for each objUSBDevice in colUSBDevices
  usbDeviceName = objUSBDevice.Caption 
  if inStr(1,usbDeviceName,"USB") then x = x & "USB Device: " & usbDeviceName & vbcrlf 'vbcrlf is a line feed remember
  Next 
Next
objFile.WriteLine x
objFile.WriteLine "*********End Generic Dev Info*********"
'Get USB details for DISKS
usbDeviceName=""
for i = 0 to 10
  DiskIndex=i
  ' WMI Query to the Win32_OperatingSystem
  x = "\\\\.\\PHYSICALDRIVE" & DiskIndex  'for a query we must use \\ for a single \
  x = "Select * from Win32_DiskDrive where DeviceID = '" & x & "'"
    
  set colItems = objWMIService.ExecQuery(x)
  for each DD In colItems
    usbDeviceName = usbDeviceName & vbcrlf & "Device " & DiskIndex & ":" & DD.Model
    usbDeviceName = usbDeviceName & " FWARE:" & DD.FirmwareRevision
    usbDeviceName = usbDeviceName & "  IFACE_TYPE:" & DD.InterfaceType  'USB
    usbDeviceName = usbDeviceName & "  MEDIA_TYPE:" &  DD.MediaType
    if not IsNull(DD.Size) then usbDeviceName = usbDeviceName & "  SIZE:" &  DD.size & vbcrlf
  Next
Next
objFile.WriteLine usbDeviceName 
objFile.WriteLine "--------------------------------------"
'Find USB drives (or a specific drive model)
set colDiskDrives = objWMIService.ExecQuery("SELECT * FROM Win32_DiskDrive")
for each objDrive In colDiskDrives
 strDeviceID = Replace(objDrive.DeviceID, "\", "\\")
 set colPartitions = objWMIService.ExecQuery ("ASSOCIATORS OF {Win32_DiskDrive.DeviceID=""" & strDeviceID & """} WHERE AssocClass = " & "Win32_DiskDriveToDiskPartition")
 for each objPartition In colPartitions
   set colLogicalDisks = objWMIService.ExecQuery("ASSOCIATORS OF {Win32_DiskPartition.DeviceID=""" & objPartition.DeviceID & """} WHERE AssocClass = " & "Win32_LogicalDiskToPartition")
   for each objLogicalDisk In colLogicalDisks
    TargetPath = TargetPath & objLogicalDisk.DeviceID & " "
    Next
 Next
Next
objFile.WriteLine "USB Drive(s) mounted at " & TargetPath
objFile.WriteLine "--------------------------------------"

'Show drive letters associated with each
set wmiServices  = GetObject ("winmgmts:{impersonationLevel=Impersonate}!//" & strComputer)
' Get physical disk drive
set wmiDiskDrives =  wmiServices.ExecQuery ( "SELECT Caption, DeviceID FROM Win32_DiskDrive")

for each wmiDiskDrive In wmiDiskDrives
  'Use the disk drive device id to find associated partition    
  set wmiDiskPartitions = wmiServices.ExecQuery("ASSOCIATORS OF {Win32_DiskDrive.DeviceID='" & wmiDiskDrive.DeviceID & "'} WHERE AssocClass = Win32_DiskDriveToDiskPartition")
  for each wmiDiskPartition In wmiDiskPartitions
    'Use partition device id to find logical disk
    set wmiLogicalDisks = wmiServices.ExecQuery ("ASSOCIATORS OF {Win32_DiskPartition.DeviceID='" & wmiDiskPartition.DeviceID & "'} WHERE AssocClass = Win32_LogicalDiskToPartition") 
    x = ""
    for each wmiLogicalDisk In wmiLogicalDisks
      x = x & wmiDiskDrive.Caption & " " & wmiDiskPartition.DeviceID & " Drive Letter " & wmiLogicalDisk.DeviceID
      objFile.WriteLine x & vbcrlf
      Next      
  Next
Next
objFile.close