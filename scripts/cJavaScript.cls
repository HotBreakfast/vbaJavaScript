Option Explicit
Private pChunk As cStringChunker
'/**
' * kind of like a script tag - adds a local script file to your code
' * @param {string} scriptFile file name
' * @return {cJavaScript} self
' */
Public Function addFile(scriptFile As String) As cJavaScript
    pChunk.addLine (readFromFile(scriptFile))
    Set addFile = Me
End Function
'/**
' * kind of like a script tag - adds a local apps script stuff
' * @param {string} scriptUrl the web app providing the code
' * @return {cJavaScript} self
' */
Public Function addAppsScript(scriptUrl As String) As cJavaScript
    Dim s As String
    
    s = simpleUrlGet(scriptUrl)
    
    '// need to do special cleaning for apps script
    pChunk.addLine (removeHtmlEscape(s))
    Set addAppsScript = removeScriptTags()

End Function
        
'/**
' * kind of like a script tag - adds a hosted file to your code
' * @param {string} scriptUrl file link
' * @return {cJavaScript} self
' */
Public Function addUrl(scriptUrl As String) As cJavaScript
    pChunk.addLine (simpleUrlGet(scriptUrl))
    Set addUrl = Me
End Function
'/**
' * kind of like a script tag - adds a local script file to your code
' * @param {string} fn file link
' * @param {boolean} complain optional complain if an error
' * @return {string} result
' */
Public Function simpleUrlGet(fn As String, Optional complain As Boolean = True) As String
    
    '// this can be changes to a client object if firewall problems
    Dim ohttp As Object
    Set ohttp = New MSXML2.ServerXMLHTTP60
    
    With ohttp
        .Open "GET", fn, False
        .Send ""
        If (.status <> 200) Then
            MsgBox ("error getting " & fn & " code " & .status & " text " & .ResponseText)
        Else
            simpleUrlGet = .ResponseText
        End If

        
    End With
End Function

'/**
' * adds code to your script
' * @param {string} scriptCode some code
' * @return {cJavaScript} self
' */
Public Function addCode(scriptCode As String) As cJavaScript
    pChunk.addLine scriptCode
    Set addCode = Me
End Function
'/**
' * returns the code
' * @return {string} the code
' */
Public Property Get code() As String
    code = pChunk.toString
End Property
'/**
' * returns convenience self for with/chaining
' * @return {cJavaScript} self
' */
Public Property Get self() As cJavaScript
    Set self = Me
End Property
'/**
' * clears the code
' * @return {cJavaScript}  self
' */
Public Function clear() As cJavaScript
    pChunk.clear
    Set clear = Me
End Function
'/**
' * expose the stringchunker
' * @return {cStringChunker}  the code chunker
' */
Public Property Get chunker() As cStringChunker
    Set chunker = pChunk
End Property

'/**
' * execute code
' * @return {ScriptControl} the script control to execute run against
' */
Public Function compile() As Variant
    Dim sc As ScriptControl
    Set sc = New ScriptControl

    ' we can't run as a method of this as paramarray cant be passed properly in VBA
    With sc
        .Language = "JScript"
        .addCode pChunk.addLine("").toString
    End With
    
    Set compile = sc
    
End Function
'/**
' * if you need to deal with arrays, this will convert back and forwards from JS to vba
' * @return {cJavaScript} self
' */
Public Function addArraySupport() As cJavaScript
    pChunk.add "var XLiberation = (function(xLiberation) {" & _
                "xliberation.getArray = function (arrayIn) {" & _
                    "return new VBArray(arrayIn).toArray();}" & _
                "xLiberation.setArray = function setArray(ja) {" & _
                    "var dict = new ActiveXObject('Scripting.Dictionary');" & _
                    "for (var i=0;i < ja.length; i++ )dict.add(i,ja[i]);" & _
                    "return dict.items();}" & _
                " return xLiberation; " & _
        "})(Xliberation || {});"
    Set addArraySupport = Me
End Function
Public Function removeHtmlEscape(t As String) As String

    Dim oXML As Object
    ' as far as i know, only << are left escaped by contentservice
    removeHtmlEscape = Replace(t, "&lt;", "<")
    
End Function
'/**
' * apps script sometimes have script tags
' * @return {cJavaScript} self
' */
Public Function removeScriptTags() As cJavaScript
    Dim s As String, t As String
    t = pChunk.toString
    Set removeScriptTags = Me
    s = Replace(Replace(t, "<script>", ""), "</script>", "")
    If (s <> t) Then
        pChunk.clear.add (s)
    End If
End Function

Private Sub Class_Initialize()
    Set pChunk = New cStringChunker
End Sub