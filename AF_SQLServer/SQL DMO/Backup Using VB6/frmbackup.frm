VERSION 5.00
Object = "{248DD890-BB45-11CF-9ABC-0080C7E7B78D}#1.0#0"; "MSWINSCK.OCX"
Begin VB.Form frmbackupmain 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Back Up"
   ClientHeight    =   3585
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   6015
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   Moveable        =   0   'False
   ScaleHeight     =   3585
   ScaleWidth      =   6015
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin MSWinsockLib.Winsock Winsockbackup 
      Left            =   120
      Top             =   240
      _ExtentX        =   741
      _ExtentY        =   741
      _Version        =   393216
   End
   Begin VB.PictureBox Pictrestore_backup 
      AutoSize        =   -1  'True
      BorderStyle     =   0  'None
      Height          =   360
      Left            =   4200
      MouseIcon       =   "frmbackup.frx":0000
      MousePointer    =   99  'Custom
      Picture         =   "frmbackup.frx":030A
      ScaleHeight     =   360
      ScaleWidth      =   1260
      TabIndex        =   11
      ToolTipText     =   "Restore Database"
      Top             =   3000
      Width           =   1260
   End
   Begin VB.PictureBox Pictbackup 
      AutoSize        =   -1  'True
      BorderStyle     =   0  'None
      Height          =   375
      Left            =   720
      MouseIcon       =   "frmbackup.frx":05A8
      MousePointer    =   99  'Custom
      Picture         =   "frmbackup.frx":08B2
      ScaleHeight     =   375
      ScaleWidth      =   1245
      TabIndex        =   10
      ToolTipText     =   "Back Database"
      Top             =   3000
      Width           =   1245
   End
   Begin VB.PictureBox Pictcan 
      AutoSize        =   -1  'True
      BorderStyle     =   0  'None
      Height          =   360
      Left            =   2520
      MouseIcon       =   "frmbackup.frx":0B5B
      MousePointer    =   99  'Custom
      Picture         =   "frmbackup.frx":0E65
      ScaleHeight     =   360
      ScaleWidth      =   1245
      TabIndex        =   9
      Top             =   3000
      Width           =   1245
   End
   Begin VB.PictureBox pb_restore 
      Height          =   255
      Left            =   720
      ScaleHeight     =   195
      ScaleWidth      =   4635
      TabIndex        =   8
      Top             =   2640
      Width           =   4695
   End
   Begin VB.Frame Frame2 
      Height          =   735
      Left            =   720
      TabIndex        =   7
      Top             =   0
      Width           =   4695
      Begin VB.PictureBox Pictfirst_time 
         AutoSize        =   -1  'True
         BorderStyle     =   0  'None
         Height          =   360
         Left            =   3000
         MouseIcon       =   "frmbackup.frx":10E0
         MousePointer    =   99  'Custom
         Picture         =   "frmbackup.frx":13EA
         ScaleHeight     =   360
         ScaleWidth      =   1485
         TabIndex        =   13
         Top             =   240
         Width           =   1485
      End
      Begin VB.PictureBox Pictadd 
         AutoSize        =   -1  'True
         BorderStyle     =   0  'None
         Height          =   360
         Left            =   360
         MouseIcon       =   "frmbackup.frx":16D3
         MousePointer    =   99  'Custom
         Picture         =   "frmbackup.frx":19DD
         ScaleHeight     =   360
         ScaleWidth      =   1485
         TabIndex        =   12
         Top             =   240
         Width           =   1485
      End
   End
   Begin VB.Frame Frame1 
      Height          =   1695
      Left            =   720
      TabIndex        =   0
      Top             =   840
      Width           =   4695
      Begin VB.TextBox txtserveripaddress 
         Height          =   350
         Left            =   1545
         TabIndex        =   3
         Top             =   240
         Width           =   2175
      End
      Begin VB.TextBox txtloginname 
         Height          =   350
         Left            =   1560
         TabIndex        =   2
         Top             =   720
         Width           =   2175
      End
      Begin VB.TextBox txtpassword 
         Height          =   350
         IMEMode         =   3  'DISABLE
         Left            =   1560
         PasswordChar    =   "*"
         TabIndex        =   1
         Top             =   1200
         Width           =   2175
      End
      Begin VB.Label Label1 
         AutoSize        =   -1  'True
         Caption         =   "Server IP Address"
         Height          =   195
         Left            =   120
         TabIndex        =   6
         Top             =   315
         Width           =   1275
      End
      Begin VB.Label Label2 
         AutoSize        =   -1  'True
         Caption         =   "Login Name"
         Height          =   195
         Left            =   120
         TabIndex        =   5
         Top             =   795
         Width           =   855
      End
      Begin VB.Label Label3 
         AutoSize        =   -1  'True
         Caption         =   "Password"
         Height          =   195
         Left            =   120
         TabIndex        =   4
         Top             =   1260
         Width           =   690
      End
   End
End
Attribute VB_Name = "frmbackupmain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Public objconn As ADODB.Connection
Dim cn As ADODB.Connection
'Dim srvname As SQLDMO.SQLServer
'Dim obackup As SQLDMO.Backup
'Dim obackupdevice As SQLDMO.BackupDevice
Private Sub Pictadd_Click()
If txtserveripaddress.Text = "" Then
MsgBox "Please Input In Server IP Address", vbCritical
Exit Sub
End If
If txtloginname.Text = "" Then
MsgBox "Please Input In User Name", vbCritical
Exit Sub
End If

Dim objbackup As ADODB.Recordset
Set objbackup = New ADODB.Recordset

Set objconn = New ADODB.Connection
objconn.Open ModuleConnectionString.ConnectionString

objbackup.Open "select * from [backup]", objconn, adOpenKeyset, adLockOptimistic
If objbackup.EOF = True Then
    Dim objrsadd As ADODB.Recordset
    Set objrsadd = New ADODB.Recordset
    objrsadd.Open "select * from [backup]", objconn, adOpenKeyset, adLockOptimistic
    objrsadd.AddNew
    objrsadd.Fields("serverip") = txtserveripaddress.Text
    objrsadd.Fields("username") = txtloginname.Text
    objrsadd.Fields("password") = txtpassword.Text
    objrsadd.Update
    MsgBox "Settings Successfully Save", vbInformation, "Alert"
Else
    Dim objrsedit As ADODB.Recordset
    Set objrsedit = New ADODB.Recordset
    objrsedit.Open "select * from [backup]", objconn, adOpenKeyset, adLockOptimistic
    objrsedit.Fields("serverip") = txtserveripaddress.Text
    objrsedit.Fields("username") = txtloginname.Text
    objrsedit.Fields("password") = txtpassword.Text
    objrsedit.Update
    MsgBox "Settings Successfully Save", vbInformation, "Alert"
End If
End Sub
Private Sub pictfirst_time_Click()
objconn.Execute "sp_addumpdevice 'Disk', 'BayViewSystem' ,'D:\BayViewSystem.bak'"
MsgBox "Successfully created", vbInformation, "Alert"
End Sub
Private Sub Form_Load()
Dim objrs As ADODB.Recordset
Set objrs = New ADODB.Recordset

Set objconn = New ADODB.Connection

objconn.Open "DSN=backup"
objrs.Open "SELECT * FROM [backup]", objconn, adOpenKeyset, adLockOptimistic

    If objrs.EOF = True Then
        txtserveripaddress.Text = Winsockbackup.LocalIP
    Else
        txtloginname.Text = objrs.Fields("username")
        txtpassword.Text = objrs.Fields("password")
        txtserveripaddress.Text = objrs.Fields("serverip")
    End If
End Sub
Private Sub pictbackup_Click()
'/\\/\//\\\/\/\/\/\/\/\/\-*-*-*/- Backuping Device */-*/-/-/-*//-/-*/-*/-//-*-/*-/
'cn.Execute "sp_addumpdevice 'Disk','bayviewschl' ,'C:\bayviewschl.bak'"
'/\\/\/\/\/\/\/\/\/\\/\\/\/\/\/-*/-*-/*-/*-/*-/**-/-/*-/*-/-/*-/*-/*-*/-/*-/*-/*/\
'objconn.Close
'Set objconn = Nothing
'set objects
'On Error GoTo erra
Set cn = New ADODB.Connection
'Set obackupdevice = New SQLDMO.BackupDevice
'Set obackup = New SQLDMO.Backup
'Set srvname = New SQLDMO.SQLServer

'we can't use dsn here just only database name
obackup.Action = SQLDMOBackup_Database
obackup.Database = "BayViewSystem"

For i = 1 To 1000
pb_restore.Value = i / 10
DoEvents
Next i
'pb_restore.Value = 0
'pb_restore.Visible = False

'device name must be that as below
obackup.Devices = "[BayViewSystem]"
obackup.BackupSetName = "Bay View Backup"
obackup.BackupSetDescription = "Full Backup Of Bay View System"
'user name is "sa" which is constant and also server ip is constant

If txtpassword.Text = "" Then
srvname.Connect (txtserveripaddress.Text), txtloginname.Text
Else
srvname.Connect (txtserveripaddress.Text), txtloginname.Text, txtpassword.Text '''''this is server ip address and also bydefault login name
End If

'srvname.Connect ("192.168.1.1"), "sa"'''''''''this is server ip address and also bydefault login name

obackup.SQLBackup srvname
MsgBox "Backup Successfully Created", vbInformation, "Alert"
pb_restore.Value = 0
'erra:
'MsgBox "Check Your Configuration Or Password Or UserName Or Server IP Address"
End Sub

Private Sub pictrestore_backup_Click()
' Create a Restore object and set action and target database properties.
'Dim srvname As SQLDMO.SQLServer

objconn.Close
Set objconn = Nothing

Dim i As Integer
For i = 1 To 1000
pb_restore.Value = i / 10
DoEvents
Next i

'pb_restore.Value = 0
'pb_restore.Visible = False

'Set srvname = New SQLDMO.SQLServer

'Dim oRestore As New SQLDMO.Restore

'oRestore.Action = SQLDMORestore_Database

oRestore.Database = "BayViewSystem"

' Example illustrates restore from a striped backup. Two source devices
' Are specified. The full database backup is indicated as the first
' Backup set by using the FileNumber property. Note: Device creation is
' Not illustrated in this example.

oRestore.Devices = "[BayViewSystem]"

'oRestore.FileNumber = 1
'oRestore.LastRestore = True

' Optional. ReplaceDatabase property ensures that any existing copy
' of the database is overwritten.

'oRestore.ReplaceDatabase = True
If txtpassword.Text = "" Then
srvname.Connect (txtserveripaddress.Text), txtloginname.Text
Else
srvname.Connect (txtserveripaddress.Text), txtloginname.Text, txtpassword.Text
End If

' Call SQLRestore method to perform the restore. In a production
' environment, consider wrapping the method call with a wait pointer
' or use Restore object events to provide feedback to the user.
' Note: Create and connect of SQLServer object used is not
' illustrated in this example.

oRestore.SQLRestore srvname
  MsgBox "DataBase Success fully Restore", vbInformation, "Alert"
pb_restore.Value = 0
End Sub
Private Sub Pictcan_Click()
Unload Me
End Sub
