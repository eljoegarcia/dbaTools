Imports VB = Microsoft.VisualBasic

Public Class UserControl1
    Inherits System.Windows.Forms.UserControl

#Region " Windows Form Designer generated code "

    Public Sub New()
        MyBase.New()

        'This call is required by the Windows Form Designer.
        InitializeComponent()

        'Add any initialization after the InitializeComponent() call

    End Sub

    'UserControl1 overrides dispose to clean up the component list.
    Protected Overloads Overrides Sub Dispose(ByVal disposing As Boolean)
        If disposing Then
            If Not (components Is Nothing) Then
                components.Dispose()
            End If
        End If
        MyBase.Dispose(disposing)
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> Private Sub InitializeComponent()
        Dim resources As System.Resources.ResourceManager = New System.Resources.ResourceManager(GetType(UserControl1))
        '
        'UserControl1
        '
        Me.BackgroundImage = CType(resources.GetObject("$this.BackgroundImage"), System.Drawing.Bitmap)
        Me.Name = "UserControl1"
        Me.Size = New System.Drawing.Size(116, 61)

    End Sub

#End Region
    '''''''''''''''''''''''''''''''''''''''''''
    'This code written by Issam Hijazi        '
    'SQL Server Database Control 2.0 (VB.NET  '
    '''''''''''''''''''''''''''''''''''''''''''

    Public Enum Way
        UseLike = 1
        UseEquel = 2
    End Enum

    Public Enum MoveWay
        MoveNext = 1
        MoveBack = 2
        MoveFirst = 3
        MoveLast = 4
    End Enum


    Dim SQLS As New SQLDMO.SQLServer()
    Dim SQLS3 As New SQLDMO.SQLServer()
    Dim RecordsetT As New ADODB.Recordset()
    Dim DatabaseT As New ADODB.Connection()
    Dim MStream As New ADODB.Stream()
    Dim ConnectionString As String
    Dim ErrorNumber
    Dim ErrorDescription
    Dim User As String, Pass As String, SrvName As String, DBName As String, SQLSta As String


    Public Function OpenConncection(ByVal Username As String, ByVal Password As String, ByVal ServerName As String, ByVal DatabaseNameIs As String)
        On Error GoTo BestHandler



        ConnectionString = "Server=" & ServerName & ";Provider=SQLOLEDB;UID=" & Username & ";PWD=" & Password & ";database=" & DatabaseNameIs & ";"

        DatabaseT.Open(ConnectionString)

        User = Username
        Pass = Password
        SrvName = ServerName
        DBName = DatabaseNameIs

BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description

    End Function

    Public Function FindRecord(ByVal ColName As String, ByVal FindWay As Way, ByVal Text As String)
        On Error GoTo BestHandler



        If FindWay = 1 Then
            RecordsetT.Find(ColName & " ='" & Text & "'", 0, ADODB.SearchDirectionEnum.adSearchForward, 1)
        Else
            RecordsetT.Find(ColName & " Like '" & Text & "%'", 0, ADODB.SearchDirectionEnum.adSearchForward, 1)
        End If
BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description

    End Function

    Public Function ChangeFieldData(ByVal FieldIndexOrName, ByVal NewData)
        On Error GoTo BestHandler
        RecordsetT.Update(FieldIndexOrName, NewData)
BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description

    End Function

    Public Function AddNewRecord()
        On Error GoTo BestHandler
        RecordsetT.AddNew()
BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description

    End Function

    Public Function CancelOperation()
        On Error GoTo BestHandler
        RecordsetT.CancelUpdate()
        RecordsetT.Cancel()
        RecordsetT.CancelBatch(ADODB.AffectEnum.adAffectCurrent)
        RecordsetT.Requery(-1)
BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description


    End Function

    Public Function DeleteRecord()
        On Error GoTo BestHandler
        RecordsetT.Delete(ADODB.AffectEnum.adAffectCurrent)
BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description

    End Function

    Public Function MoveRecord(ByVal Move As MoveWay)
        On Error GoTo BestHandler
        If Move = MoveWay.MoveFirst Then
            RecordsetT.MoveFirst()
        ElseIf Move = MoveWay.MoveLast Then
            RecordsetT.MoveLast()
        ElseIf Move = MoveWay.MoveNext Then
            RecordsetT.MoveNext()
        ElseIf Move = MoveWay.MoveBack Then
            RecordsetT.MovePrevious()
        End If
BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description

    End Function

    Public Function OpenRecordset(ByVal SQLStatment As String)
        On Error GoTo BestHandler



        RecordsetT.Open(SQLStatment, DatabaseT, ADODB.CursorTypeEnum.adOpenKeyset, ADODB.LockTypeEnum.adLockOptimistic)

        SQLSta = SQLStatment

BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description

    End Function


    Public Function Reresh()
        On Error GoTo BestHandler
        RecordsetT.Requery(-1)
BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description

    End Function

    Public Function SaveFileToDB(ByVal FilePath As String, ByVal FieldIndexOrName As String)
        On Error GoTo BestHandler

        MStream.Type = ADODB.StreamTypeEnum.adTypeBinary

        MStream.Open()

        MStream.LoadFromFile(FilePath)

        RecordsetT.Fields(FieldIndexOrName).Value = MStream.Read

        RecordsetT.Update()

        MStream.Close()

        Refresh()

BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description

    End Function

    Public Sub SaveDBToFile(ByVal FieldIndexOrName, ByVal FilePath)
        On Error GoTo BestHandler

        MStream.Type = ADODB.StreamTypeEnum.adTypeBinary

        MStream.Open()

        MStream.Write(RecordsetT.Fields(FieldIndexOrName).Value)

        MStream.SaveToFile(FilePath, ADODB.SaveOptionsEnum.adSaveCreateOverWrite)

        MStream.Close()
BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description

    End Sub

    Public Sub LoadDBPicToObject(ByVal FieldIndexOrName, ByVal ObjectName)
        On Error GoTo BestHandler

        If MStream.State = ADODB.ObjectStateEnum.adStateOpen Then MStream.Close()
        MStream.Type = ADODB.StreamTypeEnum.adTypeBinary

        MStream.Open()

        MStream.Write(RecordsetT.Fields(FieldIndexOrName).Value)

        MStream.SaveToFile("C:\temp", ADODB.SaveOptionsEnum.adSaveCreateOverWrite)


        ObjectName.Picture = Image.FromFile("C:\temp")

        MStream.Close()
BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description

    End Sub

    Private Sub UserControl_Resize()
        On Error GoTo BestHandler
        Height = 915
        Width = 1740
BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description

    End Sub

    Public Function CloseRS()
        On Error Resume Next
        RecordsetT.Close()
        DatabaseT.Close()

        ErrorNumber = Err.Number
        ErrorDescription = Err.Description

    End Function


    Public Property SQLServerStatus(ByVal SQLServerName) As Object

        Get
            On Error GoTo BestHandler



            SQLS3.Name = SQLServerName

            If SQLS3.Status = SQLDMO.SQLDMO_SVCSTATUS_TYPE.SQLDMOSvc_Running Then
                SQLServerStatus = "Running"

            ElseIf SQLS3.Status = SQLDMO.SQLDMO_SVCSTATUS_TYPE.SQLDMOSvc_Paused Then
                SQLServerStatus = "Paused"
            ElseIf SQLS3.Status = SQLDMO.SQLDMO_SVCSTATUS_TYPE.SQLDMOSvc_Paused Then
                SQLServerStatus = "Stopped"
            ElseIf SQLS3.Status = SQLDMO.SQLDMO_SVCSTATUS_TYPE.SQLDMOSvc_Unknown Then
                SQLServerStatus = "Unknown"
            ElseIf SQLS3.Status = SQLDMO.SQLDMO_SVCSTATUS_TYPE.SQLDMOSvc_Continuing Then
                SQLServerStatus = "Continuing"
            ElseIf SQLS3.Status = SQLDMO.SQLDMO_SVCSTATUS_TYPE.SQLDMOSvc_Pausing Then
                SQLServerStatus = "Pausing"
            ElseIf SQLS3.Status = SQLDMO.SQLDMO_SVCSTATUS_TYPE.SQLDMOSvc_Starting Then
                SQLServerStatus = "Starting"
            ElseIf SQLS3.Status = SQLDMO.SQLDMO_SVCSTATUS_TYPE.SQLDMOSvc_Stopping Then
                SQLServerStatus = "Stopping"
            End If

BestHandler:
            ErrorNumber = Err.Number
            ErrorDescription = Err.Description

        End Get


        Set(ByVal SQLServerStatus As Object)

        End Set

    End Property

    Public Property IfBOForEOF() As Boolean
        Get
            On Error GoTo BestHandler
            If RecordsetT.BOF = True Or RecordsetT.EOF = True Then
                IfBOForEOF = True
            End If
BestHandler:
            ErrorNumber = Err.Number
            ErrorDescription = Err.Description
        End Get

        Set(ByVal ifboforeof As Boolean)
        End Set

    End Property

    Public Property GetFieldData(ByVal FieldIndexOrName) As Object
        Get
            On Error GoTo BestHandler
            GetFieldData = RecordsetT.Fields(FieldIndexOrName)
BestHandler:
            ErrorNumber = Err.Number
            ErrorDescription = Err.Description
        End Get

        Set(ByVal getfielddata As Object)
        End Set

    End Property



    Public Function CheckAccount(ByVal ServerName As String, ByVal Username As String, ByVal Password As String) As Boolean
        On Error GoTo BestHandler
        Dim SQLS2 As New SQLDMO.SQLServer()

        On Error GoTo BestHandler
        SQLS2.Name = ServerName

        SQLS2.Connect(ServerName, Username, Password)

        CheckAccount = True



        If Err.Number = -2147023174 Then CheckAccount = False
        If Err.Number = -2147203048 Then CheckAccount = False
        If SQLS2.Status <> SQLDMO.SQLDMO_SVCSTATUS_TYPE.SQLDMOSvc_Running Then CheckAccount = False
BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description

    End Function

    Public Function StartSQLServer(ByVal ServerName As String, ByVal Username As String, ByVal Password As String)
        On Error GoTo BestHandler
        SQLS.Start(False, ServerName, Username, Password)
BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description

    End Function

    Public Function PauseSQLServer(ByVal ServerName As String)
        On Error GoTo BestHandler
        SQLS.Name = ServerName
        SQLS.Pause()
BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description

    End Function

    Public Function ContinueSQLServer(ByVal ServerName As String)
        On Error GoTo BestHandler
        SQLS.Name = ServerName
        SQLS.Continue()
BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description

    End Function

    Public Function StopSQLServer(ByVal ServerName As String)
        On Error GoTo BestHandler
        SQLS.Name = ServerName
        SQLS.Stop()
BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description

    End Function

    Public Function DeleteDatabase(ByVal DatabaseTName As String)
        On Error GoTo BestHandler
        SQLS.KillDatabase(DatabaseTName)
BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description

    End Function

    Public Function AddDatabase(ByVal DatabaseTName As String, ByVal DatabaseTFileMDF As String)
        On Error GoTo BestHandler
        SQLS.AttachDBWithSingleFile(DatabaseTName, DatabaseTFileMDF)
BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description

    End Function

    Public Function ConnectToSQLServer(ByVal ServerName As String, ByVal Username As String, ByVal Password As String)
        On Error GoTo BestHandler
        SQLS.Connect(ServerName, Username, Password)
BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description

    End Function

    Public Function DisconnectFromSQLServer()
        On Error GoTo BestHandler
        SQLS.DisConnect()
BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description

    End Function

    Public Property IsConnected() As Boolean
        Get
            On Error GoTo BestHandler
            If SQLS.IsPackage = SQLDMO.SQLDMO_PACKAGE_TYPE.SQLDMO_Unknown Then Width = 735 Else Height = 255


            IsConnected = True

            If Err.Number = -2147201022 Then IsConnected = False Else IsConnected = True
BestHandler:
            ErrorNumber = Err.Number
            ErrorDescription = Err.Description
        End Get

        Set(ByVal IsConnected As Boolean)
            ' The Set property procedure is called when the value 
            ' of a property is modified. 
            ' The value to be assigned is passed in the argument to Set. 
            IsConnected = IsConnected
        End Set

    End Property

    Public Function RepairDatabase(ByVal DatabaseTName As String)
        On Error GoTo BestHandler
        SQLS.Databases.Item(DatabaseTName).CheckAllocations(SQLDMO.SQLDMO_DBCC_REPAIR_TYPE.SQLDMORepair_None)


BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description

    End Function

    Public Function BackupDatabaseToFile(ByVal DatabaseTName As String, ByVal Path As String)
        On Error GoTo BestHandler
        On Error Resume Next
        Dim BackMeUp As SQLDMO.Backup
        BackMeUp = New SQLDMO.Backup()
        Dim DatabaseTFileName As String



        DatabaseTFileName = "C:\" & DatabaseTName & ".bak"

        BackMeUp.Database = DatabaseTName

        BackMeUp.Files = DatabaseTFileName

        BackMeUp.SQLBackup(SQLS)



        FileCopy(DatabaseTFileName, Path & "\" & DatabaseTName & ".bak")


        Kill("C:\" & DatabaseTName & ".bak")


BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description

    End Function

    Public Function RestoreDatabaseFromFile(ByVal DatabaseTName As String, ByVal Path As String)
        On Error GoTo BestHandler
        Dim oRestore As SQLDMO.Restore
        oRestore = New SQLDMO.Restore()

        FileCopy(Path & "\" & DatabaseTName & ".bak", "C:\" & DatabaseTName & ".bak")


        oRestore.Database = DatabaseTName
        oRestore.Files = "C:\" & DatabaseTName & ".bak"

        oRestore.SQLRestore(SQLS)

        Kill("C:\" & DatabaseTName & ".bak")

BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description
    End Function

    Public Property ErrorNum() As Object
        Get
            ErrorNum = ErrorNumber
        End Get
        Set(ByVal ErrorNum As Object)
        End Set
    End Property

    Public Property ErrorDes() As Object
        Get
            ErrorDes = ErrorDescription
        End Get

        Set(ByVal errordes As Object)
        End Set

    End Property

    Public Function AboutMe()
        About.ActiveForm.Show()
    End Function

    Public Function BindToMSHFlexGrid(ByVal ObjectName As Object)
        On Error GoTo BestHandler

        RecordsetT.Close()

        RecordsetT.Open(SQLSta, DatabaseT, ADODB.CursorTypeEnum.adOpenKeyset, ADODB.LockTypeEnum.adLockOptimistic)

        ObjectName.DataSource = RecordsetT
        ObjectName.Refresh()
        RecordsetT.Requery(-1)

BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description
    End Function

    Public Function BindToObject(ByVal ObjectName As Object, ByVal DataFieldName As String)
        On Error GoTo BestHandler


        ObjectName.DataSource = RecordsetT

        ObjectName.DataField = DataFieldName
        ObjectName.Refresh()

BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description

    End Function

    Public Function ListDatabases(ByVal ObjectName As Object)
        On Error GoTo BestHandler
        RecordsetT = DatabaseT.Execute("sp_databases")
        Do Until RecordsetT.EOF
            ObjectName.AddItem(RecordsetT.Fields("Database_Name"))
            RecordsetT.MoveNext()
        Loop

        RecordsetT.Close()

        RecordsetT.Open(SQLSta, DatabaseT, ADODB.CursorTypeEnum.adOpenKeyset, ADODB.LockTypeEnum.adLockOptimistic)
        RecordsetT.Requery(-1)

BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description
    End Function

    Public Function ListTables(ByVal ObjectName As Object)
        On Error GoTo BestHandler
        RecordsetT = DatabaseT.OpenSchema(ADODB.SchemaEnum.adSchemaTables)
        Do Until RecordsetT.EOF
            If VB.Left(RecordsetT.Fields("table_name").Value, 3) = "sys" Or VB.Left(RecordsetT.Fields("table_name").Value, 3) = "dtp" Then
            Else
                ObjectName.AddItem(RecordsetT.Fields("table_name").Value)
            End If

            RecordsetT.MoveNext()
        Loop

        RecordsetT.Close()

        RecordsetT.Open(SQLSta, DatabaseT, ADODB.CursorTypeEnum.adOpenKeyset, ADODB.LockTypeEnum.adLockOptimistic)
        RecordsetT.Requery(-1)

BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description
    End Function

    Public Function ListFields(ByVal ObjectName As Object, ByVal TableName As String)
        On Error GoTo BestHandler
        Dim nulls As String
        Dim cnt As Integer

        RecordsetT = DatabaseT.Execute("sp_columns [" & TableName & "]")
        Do Until RecordsetT.EOF
            cnt = cnt + 1
            If RecordsetT.Fields("nullable").Value = "0" Then
                nulls = "Not Null"
            Else
                nulls = "Null"
            End If
            ObjectName.AddItem(RecordsetT.Fields("column_name"))
            RecordsetT.MoveNext()
        Loop

        RecordsetT.Close()

        RecordsetT.Open(SQLSta, DatabaseT, ADODB.CursorTypeEnum.adOpenKeyset, ADODB.LockTypeEnum.adLockOptimistic)
        RecordsetT.Requery(-1)

BestHandler:
        ErrorNumber = Err.Number
        ErrorDescription = Err.Description
    End Function

End Class