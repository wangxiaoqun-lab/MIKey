param([string]$TaskMatlabCode, [string]$TaskCodeFile)
$ErrorActionPreference = 'Stop'
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class MIKeyRunningMatlabCom {
 [DllImport("ole32.dll", CharSet=CharSet.Unicode, PreserveSig=false)] static extern void CLSIDFromProgID(string name, out Guid clsid);
 [DllImport("oleaut32.dll", PreserveSig=false)] static extern void GetActiveObject(ref Guid clsid, IntPtr reserved, [MarshalAs(UnmanagedType.IUnknown)] out object value);
 public static object Attach() { Guid clsid; CLSIDFromProgID("Matlab.Application",out clsid); object value; GetActiveObject(ref clsid,IntPtr.Zero,out value); return value; }
}
'@
if ($TaskCodeFile) { $TaskMatlabCode = [IO.File]::ReadAllText($TaskCodeFile) }
$TaskMatlabServer = [MIKeyRunningMatlabCom]::Attach()
try { $TaskMatlabServer.Execute($TaskMatlabCode) } finally { [void][Runtime.InteropServices.Marshal]::ReleaseComObject($TaskMatlabServer) }
