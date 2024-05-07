#Region Public

#Region ConfigurationMethodsEvents

Procedure OnStart() Export 
	SessionStartParameters=UT_CommonServerCall.SessionStartParameters();

	If SessionStartParameters.ExtensionRightsAdded Then
		Exit(False, True);
	EndIf;

	UT_ApplicationParameters.Insert("SessionNumber", SessionStartParameters.SessionNumber);
	UT_ApplicationParameters.Insert("ConfigurationScriptVariant", SessionStartParameters.ConfigurationScriptVariant);

	UT_ApplicationParameters.Insert("IsLinuxClient", UT_CommonClientServer.IsLinux());
	UT_ApplicationParameters.Insert("IsWindowsClient", UT_CommonClientServer.IsWindows());
	UT_ApplicationParameters.Insert("IsWebClient", IsWebClient());
	UT_ApplicationParameters.Insert("IsPortableDistribution", UT_CommonClientServer.IsPortableDistribution());
	UT_ApplicationParameters.Insert("HTMLFieldBasedOnWebkit",
		UT_CommonClientServer.HTMLFieldBasedOnWebkit());
	UT_ApplicationParameters.Insert("AppVersion",
	UT_CommonClientServer.CurrentAppVersion());
	//UT_ApplicationParameters.Insert("ConfigurationMetadataDescriptionAdress", UT_CommonServerCall.ConfigurationMetadataDescriptionAdress());
	
	SessionParametersInStorage = New Structure;
	SessionParametersInStorage.Insert("IsLinuxClient", UT_ApplicationParameters["IsLinuxClient"]);
	SessionParametersInStorage.Insert("IsWebClient", UT_ApplicationParameters["IsWebClient"]);
	SessionParametersInStorage.Insert("IsWindowsClient", UT_ApplicationParameters["IsWindowsClient"]);
	SessionParametersInStorage.Insert("IsPortableDistribution", UT_ApplicationParameters["IsPortableDistribution"]);
	SessionParametersInStorage.Insert("HTMLFieldBasedOnWebkit", UT_ApplicationParameters["HTMLFieldBasedOnWebkit"]);
	SessionParametersInStorage.Insert("AppVersion", UT_ApplicationParameters["AppVersion"]);
	//SessionParametersInStorage.Insert("ConfigurationMetadataDescriptionAdress", UT_ApplicationParameters["ConfigurationMetadataDescriptionAdress"]);

	UT_CommonServerCall.CommonSettingsStorageSave(
	UT_CommonClientServer.ObjectKeyInSettingsStorage(),
	UT_CommonClientServer.SessionParametersSettingsKey(), SessionParametersInStorage);

EndProcedure

Procedure OnExit() Export
	UT_AdditionalLibrariesDirectory=UT_AssistiveLibrariesDirectory();
	If Not ValueIsFilled(UT_AdditionalLibrariesDirectory) Then
		Return;
	EndIf;
	Try
		BeginDeletingFiles(,UT_AdditionalLibrariesDirectory);
	Except

	EndTry;
EndProcedure

#EndRegion

// Displays the text, which users can copy.
//
// Parameters:
//   Handler - NotifyDescription - description of the procedure to be called after showing the message.
//       Returns a value like ShowQuestionToUser().
//   Text - String - an information text.
//   Title - String - Optional. window title. "Details" by default.
//
Procedure ShowDetailedInfo(Handler, Text, Title = Undefined) Export
	DialogSettings = New Structure;
	DialogSettings.Insert("SuggestDontAskAgain", False);
	DialogSettings.Insert("Picture", Undefined);
	DialogSettings.Insert("ShowPicture", False);
	DialogSettings.Insert("CanCopy", True);
	DialogSettings.Insert("DefaultButton", 0);
	DialogSettings.Insert("HighlightDefaultButton", False);
	DialogSettings.Insert("Title", Title);
	
	If Not ValueIsFilled(DialogSettings.Title) Then
		DialogSettings.Title = NStr("ru = 'Подробнее'; en = 'Details'");
	EndIf;
	
	Buttons = New ValueList;
	Buttons.Add(0, NStr("ru = 'Закрыть'; en = 'Close'"));
	
	ShowQuestionToUser(Handler, Text, Buttons, DialogSettings);
EndProcedure

// Show the question form.
//
// Parameters:
//   CompletionNotifyDescription - NotifyDescription - description of the procedures to be called 
//                                                        after the question window is closed with the following parameters:
//                                                          QuestionResult - Structure - a structure with the following properties:
//                                                            Value - a user selection result: a 
//                                                                       system enumeration value or 
//                                                                       a value associated with the clicked button. 
//                                                                       If the dialog is closed by a timeout - value
//                                                                       Timeout.
//                                                            DontAskAgain - Boolean - a user 
//                                                                                                  
//                                                                                                  selection result in the check box with the same name.
//                                                          AdditionalParameters - Structure
//   QuestionText - String - a question text.
//   Buttons                        - QuestionDialogMode, ValueList - a value list may be specified in which:
//                                       Value - contains the value connected to the button and 
//                                                  returned when the button is selected. You can 
//                                                  pass a value of the DialogReturnCode enumeration 
//                                                  or any value that can be XDTO serialized.
//                                                  
//                                       Presentation - sets the button text.
//
//   AdditionalParameters - Structure - see StandardSubsystemsClient.QuestionToUserParameters 
//
// Returns:
//   The user selection result is passed to the method specified in the NotifyDescriptionOnCompletion parameter.
//
Procedure ShowQuestionToUser(CompletionNotifyDescription, QuestionText, Buttons,
 AdditionalParameters = Undefined) Export

	If AdditionalParameters <> Undefined Then
		Parameters = AdditionalParameters;
	Else
		Parameters = New Structure;
	EndIf;

	UT_CommonClientServer.SupplementStructure(Parameters, QuestionToUserParameters(), False);

	ButtonsParameter = Buttons;

	If TypeOf(Parameters.DefaultButton) = Type("DialogReturnCode") Then
	 //@skip-warning
		Parameters.DefaultButton = DialogReturnCodeToString(Parameters.DefaultButton);
	EndIf;
	
	If TypeOf(Parameters.TimeoutButton) = Type("DialogReturnCode") Then
		Parameters.TimeoutButton = DialogReturnCodeToString(Parameters.TimeoutButton);
	EndIf;
	
	Parameters.Insert("Buttons",         ButtonsParameter);
	Parameters.Insert("MessageText", QuestionText);
	
	NotifyDescriptionForApplicationRun=CompletionNotifyDescription;
	If NotifyDescriptionForApplicationRun = Undefined Then
		NotifyDescriptionForApplicationRun=ApplicationRunEmptyNotifyDescription();
	EndIf;

	ShowQueryBox(NotifyDescriptionForApplicationRun, QuestionText, ButtonsParameter, , Parameters.DefaultButton, "",
		Parameters.TimeoutButton);

EndProcedure

// Returns a new structure with additional parameters for the ShowQuestionToUser procedure.
//
// Returns:
//  Structure - structure with the following properties:
//    * DefaultButton - Arbitrary - defines the default button by the button type or by the value 
//                                                     associated with it.
//    * Timeout - Number - a period of time in seconds in which the question window waits for user 
//                                                     to respond.
//    * TimeoutButton - Arbitrary - a button (by button type or value associated with it) on which 
//                                                     the timeout remaining seconds are displayed.
//                                                     
//    * Title - String - a question title.
//    * SuggestDontAskAgain - Boolean - if True, a check box with the same name is available in the window.
//    * DontAskAgain - Boolean - a value set by the user in the matching check box.
//                                                     
//    * LockWholeInterface - Boolean - if True, the question window opens locking all other opened 
//                                                     windows including the main one.
//    * Picture - Picture - a picture displayed in the question window.
//
Function QuestionToUserParameters() Export
	
	Parameters = New Structure;
	Parameters.Insert("DefaultButton", Undefined);
	Parameters.Insert("Timeout", 0);
	Parameters.Insert("TimeoutButton", Undefined);
	Parameters.Insert("Title", ClientApplication.GetCaption());
	Parameters.Insert("SuggestDontAskAgain", True);
	Parameters.Insert("DoNotAskAgain", False);
	Parameters.Insert("LockWholeInterface", False);
	Parameters.Insert("Picture", PictureLib.Question32);
	Return Parameters;
	
EndFunction

// Returns String Representation of type DialogReturnCode 
Function DialogReturnCodeToString(Value)

	Result = "DialogReturnCode." + String(Value);

	If Value = DialogReturnCode.Yes Then
		Result = "DialogReturnCode.Yes";
	ElsIf Value = DialogReturnCode.No Then
		Result = "DialogReturnCode.No";
	ElsIf Value = DialogReturnCode.OK Then
		Result = "DialogReturnCode.OK";
	ElsIf Value = DialogReturnCode.Cancel Then
		Result = "DialogReturnCode.Cancel";
	ElsIf Value = DialogReturnCode.Retry Then
		Result = "DialogReturnCode.Retry";
	ElsIf Value = DialogReturnCode.Abort Then
		Result = "DialogReturnCode.Abort";
	ElsIf Value = DialogReturnCode.Ignore Then
		Result = "DialogReturnCode.Ignore";
	EndIf;

	Return Result;

EndFunction

#Region ExecuteAlgorithms

Function ExecuteAlgorithm(AlgorithmRef, IncomingParameters = Undefined, ExecutionError = False,
	ErrorMessage = "") Export
	Return UT_AlgorithmsClientServer.ExecuteAlgorithm(AlgorithmRef, IncomingParameters, ExecutionError,
		ErrorMessage)
EndFunction

#EndRegion

#Region Debug

Procedure OpenDebuggingConsole(DebuggingObjectType, DebuggingData, ConsoleFormUnique = Undefined) Export
	If Upper(DebuggingObjectType) = "QUERY" Then
		ConsoleFormName = "DataProcessor.UT_QueryConsole.Form";
	ElsIf Upper(DebuggingObjectType) = "DATACOMPOSITIONSCHEMA" Then
		ConsoleFormName = "Report.UT_ReportsConsole.Form";
	ElsIf Upper(DebuggingObjectType) = "DATABASEOBJECT" Then
		ConsoleFormName = "DataProcessor.UT_ObjectsAttributesEditor.ObjectForm";
	ElsIf Upper(DebuggingObjectType) = "HTTPREQUEST" Then
		ConsoleFormName = "DataProcessor.UT_HTTPRequestConsole.Form";
	Else
		Return;
	EndIf;

	FormParameters = New Structure;
	FormParameters.Insert("DebuggingData", DebuggingData);

	If ConsoleFormUnique = Undefined Then
		Uniqueness = New UUID;
	Else
		Uniqueness = ConsoleFormUnique;
	EndIf;

	OpenForm(ConsoleFormName, FormParameters, , Uniqueness);

EndProcedure

Procedure  RunDebugConsoleByDebugDataSettingsKey(DebugSettingsKey,User=Undefined, 
	FormID = Undefined) Export
	If Not ValueIsFilled(DebugSettingsKey) Then
		Return;
	EndIf;

	DebugData = UT_CommonServerCall.DebuggingObjectDataStructureFromSystemSettingsStorage(
		DebugSettingsKey,user, FormID);

	If DebugData = Undefined Then
		Return;
	EndIf;

	OpenDebuggingConsole(DebugData.DebuggingObjectType, DebugData.DebuggingObjectAddress);
EndProcedure

#EndRegion

Function IsWebClient() Export
	#If WebClient Then
		Return True;
	#Else
		Return False;
	#EndIf
EndFunction

Function ApplicationRunEmptyNotifyDescription() Export
	Return New NotifyDescription("BeginRunningApplicationEndEmpty", ThisObject);
EndFunction

Procedure BeginRunningApplicationEndEmpty(ReturnCode, AdditionalParameters) Export
	If ReturnCode = Undefined Then
		Return;
	EndIf;
EndProcedure

Procedure OpenTextEditingForm(Text, OnCloseNotifyDescription, Title = "",
	WindowOpeningMode = Undefined) Export
	FormParameters = New Structure;
	FormParameters.Insert("Text", Text);
	FormParameters.Insert("Title", Title);

	If WindowOpeningMode = Undefined Then
		OpenForm("CommonForm.UT_TextEditingForm", FormParameters, , , , , OnCloseNotifyDescription);
	Else
		OpenForm("CommonForm.UT_TextEditingForm", FormParameters, , , , , OnCloseNotifyDescription,
			WindowOpeningMode);
	EndIf;
EndProcedure

Procedure OpenValueListChoiceItemsForm(List, OnCloseNotifyDescription, Title = "",
	ItemsType = Undefined, CheckVisible = True, PresentationVisible = True, PickMode = True,
	ReturnOnlySelectedValues = True, WindowOpeningMode = Undefined, AvailableValues = Undefined) Export
	FormParameters = New Structure;
	FormParameters.Insert("List", List);
	FormParameters.Insert("Title", Title);
	FormParameters.Insert("ReturnOnlySelectedValues", ReturnOnlySelectedValues);
	FormParameters.Insert("CheckVisible", CheckVisible);
	FormParameters.Insert("PresentationVisible", PresentationVisible);
	FormParameters.Insert("PickMode", PickMode);
	If ItemsType <> Undefined Then
		FormParameters.Insert("ItemsType", ItemsType);
	EndIf;
	If AvailableValues <> Undefined Then
		FormParameters.Insert("AvailableValues", AvailableValues);
	Endif;

	If WindowOpeningMode = Undefined Then
		OpenForm("CommonForm.UT_ValueListEditingForm", FormParameters, , , , ,
			OnCloseNotifyDescription);
	Else
		OpenForm("CommonForm.UT_ValueListEditingForm", FormParameters, , , , ,
			OnCloseNotifyDescription, WindowOpeningMode);
	EndIf;
EndProcedure

Procedure EditObject(ObjectRef) Export
	AvailableForEditingObjectsArray=UT_CommonClientCached.DataBaseObjectEditorAvailableObjectsTypes();
	If AvailableForEditingObjectsArray.Find(TypeOf(ObjectRef)) = Undefined Then
		Return;
	EndIf;

	FormParameters = New Structure;
	FormParameters.Insert("mObjectRef", ObjectRef);

	OpenForm("DataProcessor.UT_ObjectsAttributesEditor.Form", FormParameters);
EndProcedure

Procedure EditJSON(JSONString, ViewMode, OnEndNotifyDescription = Undefined) Export
	Parameters=New Structure;
	Parameters.Insert("JSONString", JSONString);
	Parameters.Insert("ViewMode", ViewMode);

	If OnEndNotifyDescription = Undefined then
		OpenForm("DataProcessor.UT_JSONEditor.Form", Parameters);
	else
		OpenForm("DataProcessor.UT_JSONEditor.Form", Parameters, , , , , OnEndNotifyDescription);
	Endif;
EndProcedure

Procedure ОpenDynamicList(MetadataObjectName, OnEndNotifyDescription = Undefined) Export
	ParametersStructure = New Structure("MetadataObjectName", MetadataObjectName);

	If OnEndNotifyDescription = Undefined Then
		OpenForm("DataProcessor.UT_DynamicList.Form", ParametersStructure, , MetadataObjectName);
	Else
		OpenForm("DataProcessor.UT_DynamicList.Form", ParametersStructure, , MetadataObjectName, , ,
			OnEndNotifyDescription);
	EndIf;

EndProcedure

Procedure FindObjectRefs(ObjectRef) Export
	FormParameters=New Structure;
	FormParameters.Insert("SearchObject", ObjectRef);

	OpenForm("DataProcessor.UT_ObjectReferencesSearch.Form", FormParameters);

EndProcedure

Procedure AskQuestionToDeveloper() Export
	BeginRunningApplication(ApplicationRunEmptyNotifyDescription(),
		"https://github.com/i-neti/tools_ui_1c_int/issues");

EndProcedure

Procedure OpenAboutPage() Export
	BeginRunningApplication(ApplicationRunEmptyNotifyDescription(), "https://github.com/i-neti/tools_ui_1c_int");

EndProcedure

Procedure OpenPortableToolsDebugSpecificityPage () Export
	BeginRunningApplication(ApplicationRunEmptyNotifyDescription(),
		"https://github.com/cpr1c/tools_ui_1c/wiki/Portable-Tools-Debug-Specificity");

EndProcedure

Procedure RunToolsUpdateCheck() Export
	FormParameters = New Structure;;
	OpenForm("DataProcessor.UT_Support.Form.UpdateTools", FormParameters);
EndProcedure

Procedure OpenNewToolForm(SourceForm)
	OpenForm(SourceForm.FormName, , , New UUID, , , , FormWindowOpeningMode.Independent);
EndProcedure

Procedure CompareSpreadsheetDocumentsFiles(FilePath1, FilePath2, LeftTitle = "Left", RightTitle = "Right") Export

	FilesToBePlaced = New Array;
	FilesToBePlaced.Add(New TransferableFileDescription(FilePath1));
	FilesToBePlaced.Add(New TransferableFileDescription(FilePath2));
	PlacedFiles = New Array;
	If Not PutFiles(FilesToBePlaced, PlacedFiles, , False) Then
		Return;
	EndIf;
	LeftSpreadsheetDocument  = PlacedFiles[0].Location;
	RightSpreadsheetDocument = PlacedFiles[1].Location;

	CompareSpreadsheetDocuments(LeftSpreadsheetDocument, RightSpreadsheetDocument, LeftTitle, RightTitle);

EndProcedure

Procedure CompareSpreadsheetDocuments(SpreadsheetDocumentAddressInTempStorage1,
	SpreadsheetDocumentAddressInTempStorage2, LeftTitle = "Left", RightTitle = "Right") Export

	SpreadsheetDocumentsStructure = New Structure("Left, Right", SpreadsheetDocumentAddressInTempStorage1,
		SpreadsheetDocumentAddressInTempStorage2);
	SpreadsheetDocumentsAddress = PutToTempStorage(SpreadsheetDocumentsStructure, Undefined);

	FormOpenParameters = New Structure("SpreadsheetDocumentsAddress, LeftTitle, RightTitle",
		SpreadsheetDocumentsAddress, LeftTitle, RightTitle);
	OpenForm("CommonForm.UT_SpreadsheetDocumentsComparison", FormOpenParameters, ThisObject);

EndProcedure

Function OpenInformationForSupportService() Export
	Info = InformationForSupportService();
	
	OutputString = InformationForSupportServiceAsString(Info);
    OpenTextEditingForm(OutputString,Undefined ,NStr("ru = 'Информация для тех поддержки';en = 'Information for Support Service'", ));
EndFunction

#Region ToolsAttachableCommandMethods

Procedure Attachable_ExecuteToolsCommonCommand(Form, Command) Export
	If Command.Name = "UT_OpenNewToolForm" Then
		OpenNewToolForm(Form);
	Endif;

EndProcedure

#EndRegion

#Region SSLCommands

Procedure AddObjectsToComparison(ObjectsArray, Context) Export
	UT_CommonClientServer.AddObjectsArrayToCompare(ObjectsArray);
EndProcedure

Procedure UploadObjectsToXML(ObjectsArray, Context) Export
	FileURLInTempStorage="";
	UT_CommonServerCall.UploadObjectsToXMLonServer(ObjectsArray, FileURLInTempStorage,
		Context.Form.UUID);

	If IsTempStorageURL(FileURLInTempStorage) Then
		FileName="Uploading file.xml";
		GetFile(FileURLInTempStorage, FileName);
	EndIf;

EndProcedure

Procedure EditObjectCommandHandler(ObjectRef, Context) Export
	EditObject(ObjectRef);
EndProcedure

Procedure FindObjectRefsCommandHandler(ObjectRef, Context) Export
	FindObjectRefs(ObjectRef);
EndProcedure

Procedure OpenAdditionalDataProcessorDebugSettings(ObjectRef) Export
	FormParameters=New Structure;
	FormParameters.Insert("AdditionalDataProcessor", ObjectRef);

	OpenForm("CommonForm.UT_AdditionalDataProcessorDebugSettings", FormParameters);
EndProcedure

#EndRegion
#Region TypesEditingAndVariables

// Procedure - Edit type
//
// Parameters:
//  DataType					 - TypesDescription , Undefined -  Current value type
//  StartMode					 - Number - type editor start mode
// 0- selection of stored types
// 1- type for query
// 2- type for field DCS
// 3- type for parameter DCS 
// 4-Reference types without composite types
//  StandardProcessing			 - Boolean - StartChoise event standard processing
//  FormOwner					 - 	 - 
//  OnEndNotifyDescription	 - 	 - 
//
Procedure EditType(DataType, StartMode, StandardProcessing, FormOwner, OnEndNotifyDescription,
	TypesSet=Undefined) Export
	StandardProcessing=False;

	FormParameters=New Structure;
	FormParameters.Insert("DataType", DataType);
	If TypesSet = Undefined Then
		FormParameters.Insert("StartMode", StartMode);
	Else
		FormParameters.Insert("TypesSet", TypesSet);
	EndIf;
	OpenForm("CommonForm.UT_ValueTypeEditor", FormParameters, FormOwner, , , , OnEndNotifyDescription,
		FormWindowOpeningMode.LockOwnerWindow);
EndProcedure

// New parameters of value table editing
//
// Return type:
//  Structure - New parameters of value table editing
// * SerializeToXML - Boolean - If TRUE, then the string presentation of VT wiil be computed with UT_Common.ValueFromXMLString and UT_Common.ValueToXMLString.
// If FALSE, then with platform methods ValueToStringInternal and ValueFromStringInternal
// ReadOnly - boolean - if true table will open to readonly ( only view)
Function ValueTableNewEditingParameters() Export
	Structure = New Structure;
	Structure.Insert("SerializeToXML", False);
	Structure.Insert("ReadOnly", False);
	
	Return Structure;
EndFunction

// Edit value table
//
// Parameters:
//  ValueTableAsString - String - Value table string presentation
//  FormOwner - ClientApplicationForm - 
//  OnEndNotifyDescription - NotifyDescription - Will be executed on end
//  EditingParameters - Structure - See ValueTableNewEditingParameters
Procedure EditValueTable(ValueTableAsString, FormOwner,
	OnEndNotifyDescription = Undefined, EditingParameters = Undefined) Export
	FormParameters=New Structure;
	FormParameters.Insert("ValueTableAsString", ValueTableAsString);
	If EditingParameters <> Undefined Then
		For Each KeyValue In EditingParameters Do
			FormParameters.Insert(KeyValue.Key, KeyValue.Value);
		EndDo;
	EndIf;

	OpenForm("CommonForm.UT_ValueTableEditor", FormParameters, FormOwner, , , ,
		OnEndNotifyDescription);
EndProcedure

Procedure EditSpreadsheetDocument(SpreadsheetDocument, FormTitle,
	CompletionNotifyDescription = Undefined) export
	
	OpeningParameters = New Structure;
	OpeningParameters.Insert("DocumentName", FormTitle);
	OpeningParameters.Insert("SpreadsheetDocument", SpreadsheetDocument);

	OpenForm("CommonForm.UT_SpreadsheetDocumentEditor", OpeningParameters);
EndProcedure

#EndRegion

#Region FormItemsEvents

Procedure FormFieldClear(Form, Item,StandardProcessing) Export
	Item.TypeRestriction = New TypeDescription;
EndProcedure

Procedure FormFieldValueStartChoice(Form, Item, Value, StandardProcessing,
	EmptyTypeNotifyDescription = Undefined, TypesSet = Undefined) Export

	IF Value = Undefined Then
		StandardProcessing = False;

		FormParameters=New Structure;
		FormParameters.Insert("CompositeTypeAvailable", False);
		FormParameters.Insert("ChoiceMode", True);
		IF TypesSet = Undefined Then
			FormParameters.Insert("TypesSet", "Refs,Primitive,UUID");
		Else
			FormParameters.Insert("TypesSet", TypesSet);
		Endif;

		NotifyAdditionalParameters = New Structure;
		NotifyAdditionalParameters.Insert("Form", Form);
		NotifyAdditionalParameters.Insert("Item", Item);
		NotifyAdditionalParameters.Insert("EmptyTypeNotifyDescription", EmptyTypeNotifyDescription);

		OpenForm("CommonForm.UT_ValueTypeEditor", FormParameters, Item, , , ,
			New NotifyDescription("FormFieldValueStartChoiceTypeChoiceEnd", ThisObject,
			NotifyAdditionalParameters), FormWindowOpeningMode.LockOwnerWindow);

	ElsIf Item.TypeRestriction <> New TypeDescription Then
		NewValue = Item.TypeRestriction.AdjustValue(Value);
		If NewValue <> Value Then
			Types = New Array;
			Types.Add(TypeOf(Value));
			Item.TypeRestriction = New TypeDescription(Types);
		EndIf;
		//OpenForm("Catalog._DemoBankAccounts.ChoiceForm", , Item);
	EndIf;
EndProcedure

Procedure FormFieldValueStartChoiceTypeChoiceEnd(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;
	AdditionalParameters.Item.TypeRestriction = Result.Description;

	If Result.Description.Types().Count() = 0 Then
		Return;
	EndIf;

	ValueType = Result.Description.Types()[0];
	EmptyTypeValue = Undefined;
	OpenChoiceForm = False;
	
	If ValueType = Type("Number") Then
		EmptyTypeValue = 0;
	ElsIf ValueType = Type("String") Then 
		EmptyTypeValue = "";
	ElsIf ValueType = Type("Date") Then 
		EmptyTypeValue = '00010101';
	ElsIf ValueType = Type("Boolean") Then 
		EmptyTypeValue = False;
	Else
		EmptyTypeValue = New (ValueType);
		OpenChoiceForm = True;
	EndIf;

	IF TypeOf(AdditionalParameters.EmptyTypeNotifyDescription) = Type("NotifyDescription") Then
		ExecuteNotifyProcessing(AdditionalParameters.EmptyTypeNotifyDescription, EmptyTypeValue);
	EndIf;

	If Not OpenChoiceForm Then
		Return;
	EndIf;
	
	ObjectName = UT_Common.TableNameByRef(EmptyTypeValue);
	If Result.UseDynamicListForRefValueSelection Then  
		FormParameters = New Structure;
		FormParameters.Insert("MetadataObjectName", ObjectName);
		FormParameters.Insert("ChoiceMode", True);
		
		OpenForm("DataProcessor.UT_DynamicList.Form", FormParameters, AdditionalParameters.Item);	
	Else
		OpenForm(ObjectName + ".ChoiceForm", , AdditionalParameters.Item);
	EndIf;
EndProcedure


Procedure FormFieldFileNameStartChoice (FileDescriptionStructure, Item, ChoiseData, StandardProcessing,
	DialogMode, OnEndNotifyDescription) Export
	StandardProcessing=False;

	NotifyAdditionalParameters=New Structure;
	NotifyAdditionalParameters.Insert("Item", Item);
	NotifyAdditionalParameters.Insert("FileDescriptionStructure", FileDescriptionStructure);
	NotifyAdditionalParameters.Insert("DialogMode", DialogMode);
	NotifyAdditionalParameters.Insert("OnEndNotifyDescription", OnEndNotifyDescription);

	AttachFileSystemExtensionWithPossibleInstallation(
		New NotifyDescription("FormFieldFileNameStartChoiceEndAttachFileSystemExtension",
		ThisObject, NotifyAdditionalParameters));
EndProcedure

Procedure FormFieldFileNameStartChoiceEndAttachFileSystemExtension(Connected,
	AdditionalParameters) Export
	FileChoise = FileSelectionDialogByDescriptionStructureOfSelectedFile(AdditionalParameters.DialogMode,
		AdditionalParameters.FileDescriptionStructure);
	FileChoise.Show(AdditionalParameters.OnEndNotifyDescription);
EndProcedure

#EndRegion

#Region ToolsAssistiveLibraries

Procedure SaveAssistiveLibrariesAtClientOnStart() Export
	LibrariesDirectory=UT_AssistiveLibrariesDirectory();
	
	//1. Clear directory . it's separate for each database 
	Message(LibrariesDirectory);
EndProcedure

// Assistive libraries directory
// 
// Return type:
//  String - Assistive libraries directory
Function UT_AssistiveLibrariesDirectory() Export
	FileVariablesStructure=SessionFileVariablesStructure();
	If Not FileVariablesStructure.Property("UserDataWorkingDirectory") Then
		Return "";
	EndIf;
	
	Return FileVariablesStructure.UserDataWorkingDirectory + ?(StrEndsWith(
		FileVariablesStructure.UserDataWorkingDirectory, GetPathSeparator()), "",
		GetPathSeparator()) + "tools_ui_1c_int" + GetPathSeparator() + 
		Format(UT_CommonClientServer.Version(), "NG=0;");
EndFunction
#EndRegion

#Region ValueStorage

Procedure EditValueStorage(Form, ValueTempStorageUrlOrValue,
	NotifyDescription = Undefined) Export

	If NotifyDescription = Undefined Then
		NotifyDescriptionParameters = New Structure;
		NotifyDescriptionParameters.Insert("Form", Form);
		NotifyDescriptionParameters.Insert("ValueTempStorageUrlOrValue",
			ValueTempStorageUrlOrValue);
		OnCloseNotifyDescription = New NotifyDescription("EditWriteSettingsOnEnd", ThisObject,
			NotifyDescriptionParameters);
	Else
		OnCloseNotifyDescription = NotifyDescription;
	EndIf;

	FormParameters = New Structure;
	FormParameters.Insert("ValueStorageData", ValueTempStorageUrlOrValue);

	OpenForm("CommonForm.UT_ValueStorageForm", FormParameters, Form, Form.UUID, , ,
		OnCloseNotifyDescription, FormWindowOpeningMode.LockOwnerWindow);

EndProcedure

Procedure EditValueStorageOnEnd(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	//	Form=AdditionalParameters.Form;
EndProcedure

#EndRegion

#Region WriteSettings

Procedure EditWriteSettings(Form) Export
	FormParameters = New Structure;
	FormParameters.Insert("WriteSettings", UT_CommonClientServer.FormWriteSettings(Form));
	
	If Form.FormName ="DataProcessor.UT_ObjectsAttributesEditor.Form.ObjectForm" Then
		TypeArray = New Array;
		TypeArray.Add(TypeOf(Form.mObjectRef));
		
		FormParameters.Insert("ObjectType", New TypeDescription(TypeArray));
	EndIf;

	NotifyDescriptionParameters = New Structure;
	NotifyDescriptionParameters.Insert("Form", Form);
	OnCloseNotifyDescription = New NotifyDescription("EditWriteSettingsOnEnd", ThisObject,
		NotifyDescriptionParameters);

	OpenForm("CommonForm.UT_WriteSettings", FormParameters, Form, , , , OnCloseNotifyDescription,
		FormWindowOpeningMode.LockOwnerWindow);
EndProcedure

Procedure EditWriteSettingsOnEnd(Result, AdditionalParameters) Export
	If Result = Undefined Then
		Return;
	EndIf;

	Form = AdditionalParameters.Form;

	UT_CommonClientServer.SetOnFormWriteParameters(Form, Result);
EndProcedure

#EndRegion

#Region SaveAndReadConsoleData

Function EmptySelectedFileFormatDescription() Export
	Description=New Structure;
	Description.Insert("Extension", "");
	Description.Insert("Name", "");
	Description.Insert("Filter", "");

	Return Description;
EndFunction

Procedure AddFormatToSavingFileDescription(DescriptionStructureOfSelectedFile, FormatName, FileExtension, Filter = "") Export
	FileFormat=EmptySelectedFileFormatDescription();
	FileFormat.Name=FormatName;
	FileFormat.Extension=FileExtension;
	FileFormat.Filter = Filter;
	DescriptionStructureOfSelectedFile.Formats.Add(FileFormat);
EndProcedure

Function EmptyDescriptionStructureOfSelectedFile() Export
	DescriptionStructure=New Structure;
	DescriptionStructure.Insert("FileName", "");
	DescriptionStructure.Insert("SerializableFileFormats", New Array);
	DescriptionStructure.Insert("Formats", New Array);

	Return DescriptionStructure;
EndFunction

Function FileSelectionDialogByDescriptionStructureOfSelectedFile(Mode, DescriptionStructureOfSelectedFile) Export
	// You need to request a file name.
	FileSelection = New FileDialog(Mode);
	FileSelection.Multiselect = False;
	
	//Linux has problems with selecting a file if there is a dash in the existing one
	If Not (UT_CommonClientServer.IsLinux() And Find(DescriptionStructureOfSelectedFile.FileName, "-") > 0) Then
		FileSelection.FullFileName = DescriptionStructureOfSelectedFile.FileName;
	EndIf;

	Filter="";
	For each CurrentFileFormat In DescriptionStructureOfSelectedFile.Formats Do
		FormatExtension=CurrentFileFormat.Extension;
		If ValueIsFilled(FormatExtension) Then
			FormatFilter="*." + FormatExtension;
		Else
			FormatFilter="*.*";
		EndIf;
		
		If ValueIsFilled(CurrentFileFormat.Filter) Then
			FormatFilter = CurrentFileFormat.Filter;
		EndIf;

		Filter=Filter + ?(ValueIsFilled(Filter), "|", "") + StrTemplate("%1|%2", CurrentFileFormat.Name, FormatFilter);
	EndDo;

	FileSelection.Filter = Filter;

	If DescriptionStructureOfSelectedFile.SerializableFileFormats.Count() > 0 Then
		FileSelection.DefaultExt=DescriptionStructureOfSelectedFile.SerializableFileFormats[0];
	ElsIf DescriptionStructureOfSelectedFile.Formats.Count() > 0 Then
		FileSelection.DefaultExt=DescriptionStructureOfSelectedFile.Formats[0].Extension;
	EndIf;

	Return FileSelection;
EndFunction

#Region SaveConsoleData

// Description
// 
// Parameters:
// 	SaveAs - Boolean - Is file saving mode enabled AS. I.e. always ask where to save, even if there is already a file name
// 	SavedFilesDescriptionStructure -Structure - Contains the information necessary to identify the file to save
// 		Contains the fields:
// 			FileName- String - Name of the saved file. If not specified, a dialog for saving will appear
// 			Extension- String- Extension of the saved file
// 			SavedFormatName- String- description of the saved file format
// 	SavedDataUrl - String- The address in the temporary storage with the stored value. The stored data will be additionally implemented using a JSON serializer.
// 	OnEndNotifyDescription- NotifyDescription- Notify description after data saved to file
Procedure SaveConsoleDataToFile(ConsoleName, SaveAs, SavedFilesDescriptionStructure,
	SavedDataUrl, OnEndNotifyDescription) Export

	NotifyAdditionalParameters=New Structure;
	NotifyAdditionalParameters.Insert("SaveAs", SaveAs);
	NotifyAdditionalParameters.Insert("SavedFilesDescriptionStructure", SavedFilesDescriptionStructure);
	NotifyAdditionalParameters.Insert("SavedDataUrl", SavedDataUrl);
	NotifyAdditionalParameters.Insert("OnEndNotifyDescription", OnEndNotifyDescription);
	NotifyAdditionalParameters.Insert("ConsoleName", ConsoleName);

	AttachFileSystemExtensionWithPossibleInstallation(
		New  NotifyDescription ("SaveConsoleDataToFileAfterFileSystemExtensionConnection", ThisObject,
		NotifyAdditionalParameters));

EndProcedure

Procedure SaveConsoleDataToFileAfterFileSystemExtensionConnection(Connected, AdditionalParameters) Export
	SaveAS = AdditionalParameters.SaveAs;
	SavedFilesDescriptionStructure=AdditionalParameters.SavedFilesDescriptionStructure;

	If SaveAS Or SavedFilesDescriptionStructure.FileName = "" Then
		FileSelection = FileSelectionDialogByDescriptionStructureOfSelectedFile(FileDialogMode.Save,
			SavedFilesDescriptionStructure);
		FileSelection.Show(New NotifyDescription("SaveConsoleDataToFileAfterFileNameChoose", ThisObject,
			AdditionalParameters));
	Else
		SaveConsoleDataToFileBeginGettingFile(SavedFilesDescriptionStructure.FileName,
			AdditionalParameters);
	EndIf;

EndProcedure

Procedure SaveConsoleDataToFileAfterFileNameChoose(SelectedFiles, AdditionalParameters) Export
	If SelectedFiles = Undefined Then
		Return;
	Endif;

	If SelectedFiles.Count() = 0 Then
		Return;
	Endif;

	SaveConsoleDataToFileBeginGettingFile(SelectedFiles[0], AdditionalParameters);
EndProcedure

Procedure SaveConsoleDataToFileBeginGettingFile(FileName, AdditionalParameters) Export

	PreparedDateToSave=UT_CommonServerCall.ConsolePreparedDataForFileWriting(
		AdditionalParameters.ConsoleName, FileName, AdditionalParameters.SavedDataUrl,
		AdditionalParameters.SavedFilesDescriptionStructure);
	ReceivedFiles = New Array;
	ReceivedFiles.Add(New TransferableFileDescription(FileName, PreparedDateToSave));
	BeginGettingFiles(New NotifyDescription("SaveConsoleDataToFileAfterGettingFiles", ThisObject,
		AdditionalParameters), ReceivedFiles, FileName, False);
EndProcedure

Procedure SaveConsoleDataToFileAfterGettingFiles(ReceivedFiles, AdditionalParameters) Export

	NotificationProcessing = AdditionalParameters.OnEndNotifyDescription;

	If ReceivedFiles = Undefined Then

		If NotificationProcessing <> Undefined Then
			ExecuteNotifyProcessing(NotificationProcessing, Undefined);
		EndIf;
	Else
		If UT_CommonClientServer.PlatformVersionNotLess("8.3.13") Then
			FileName = ReceivedFiles[0].FullName;
		Else
			FileName = ReceivedFiles[0].Name;
		EndIf;
		If NotificationProcessing <> Undefined Then
			ExecuteNotifyProcessing(NotificationProcessing, FileName);
		EndIf;

	EndIf;

EndProcedure

#EndRegion

#Region ConsoleDataReading

Procedure ReadConsoleFromFile(ConsoleName, ReadableFileDescriptionStructure, OnEndNotifyDescription, WithoutFileSelection = False) Export

	NotifyAdditionalParameters=New Structure;
	NotifyAdditionalParameters.Insert("ReadableFileDescriptionStructure", ReadableFileDescriptionStructure);
	NotifyAdditionalParameters.Insert("OnEndNotifyDescription", OnEndNotifyDescription);
	NotifyAdditionalParameters.Insert("ConsoleName", ConsoleName);
	NotifyAdditionalParameters.Insert("WithoutFileSelection", WithoutFileSelection);

	AttachFileSystemExtensionWithPossibleInstallation(
		New NotifyDescription("ReadConsoleFromFileAfterExtensionConnection", ThisObject,
		NotifyAdditionalParameters));

EndProcedure

Procedure ReadConsoleFromFileAfterExtensionConnection(Connected, AdditionalParameters) Export

	UploadFileName  = AdditionalParameters.ReadableFileDescriptionStructure.FileName;
	WithoutFileSelection = AdditionalParameters.WithoutFileSelection;

	If Connected Then

		If WithoutFileSelection Then
			If ValueIsFilled(UploadFileName) Then
				PutableFiles=New Array;
				PutableFiles.Add(New TransferableFileDescription(UploadFileName));

				BeginPuttingFiles(
					New NotifyDescription("ReadConsoleFromFileAfterPutFiles", ThisObject,
					AdditionalParameters), PutableFiles, , False);
			EndIf;
		Else
			FileChoose = FileSelectionDialogByDescriptionStructureOfSelectedFile(FileDialogMode.Open,
				AdditionalParameters.ReadableFileDescriptionStructure);

			FileChoose.Show(New NotifyDescription("ReadConsoleFromFileAfterFileChoose", ThisObject,
				AdditionalParameters));
		EndIf;
	Else
		PutableFiles=New Array;
		PutableFiles.Add(New TransferableFileDescription(UploadFileName));

		BeginPuttingFiles(
			New NotifyDescription("ReadConsoleFromFileAfterPutFiles", ThisObject,
			AdditionalParameters), PutableFiles, , UploadFileName = "");

	EndIf;

EndProcedure

Procedure ReadConsoleFromFileAfterFileChoose(SelectedFiles, AdditionalParameters) Export

	If SelectedFiles = Undefined Then
		Return;
	EndIf;

	If SelectedFiles.Count() = 0 Then
		Return;
	EndIf;

	PutableFiles=New Array;
	PutableFiles.Add(New TransferableFileDescription(SelectedFiles[0]));

	BeginPuttingFiles(
				New NotifyDescription("ReadConsoleFromFileAfterPutFiles", ThisObject,
		AdditionalParameters), PutableFiles, , False);
EndProcedure

Procedure ReadConsoleFromFileAfterPutFiles(PuttedFiles, AdditionalParameters) Export

	If PuttedFiles = Undefined Then
		Return;
		
	EndIf;

	ReadConsoleFromFileProcessingFileUploading(PuttedFiles, AdditionalParameters);
EndProcedure

Procedure ReadConsoleFromFileProcessingFileUploading(PuttedFiles, AdditionalParameters)

	ResultStructure=Undefined;

	For Each PuttedFile In PuttedFiles Do

		If PuttedFile.Location <> "" Then

			ResultStructure=New Structure;
			ResultStructure.Insert("Url", PuttedFile.Location);
			If UT_CommonClientServer.PlatformVersionNotLess("8.3.13") Then
				ResultStructure.Insert("FileName", PuttedFile.FullName);
			Else
				ResultStructure.Insert("FileName", PuttedFile.Name);
			EndIf;
		
			Break;
		
		EndIf;

	EndDo;

	ExecuteNotifyProcessing(AdditionalParameters.OnEndNotifyDescription, ResultStructure);

EndProcedure

#EndRegion

#EndRegion

#Region FileSystemExtensionConnectAndSetup

Procedure AttachFileSystemExtensionWithPossibleInstallation(OnEndNotifyDescription, AfterInstall = False) Export
	NotifyAdditionalParameters=New Structure;
	NotifyAdditionalParameters.Insert("OnEndNotifyDescription", OnEndNotifyDescription);
	NotifyAdditionalParameters.Insert("AfterInstall", AfterInstall);

	BeginAttachingFileSystemExtension(
		New NotifyDescription("AttachFileSystemExtensionWithPossibleInstallationOnEndExtensionConnect",
		ThisObject, NotifyAdditionalParameters));

EndProcedure

Procedure AttachFileSystemExtensionWithPossibleInstallationOnEndExtensionConnect(Connected,
	AdditionalParameters) Export

	If Connected Then
		SessionFileVariablesStructure=UT_ApplicationParameters[SessionFileVariablesParameterName()];
		If SessionFileVariablesStructure = Undefined Then
			ReadMainSessionFileVariablesToApplicationParameters(
				New NotifyDescription("AttachFileSystemExtensionWithPossibleInstallationOnEndSessionFileVariablesReading",
				ThisObject, AdditionalParameters));
		Else
			ExecuteNotifyProcessing(AdditionalParameters.OnEndNotifyDescription, True);
		EndIf;
	ElsIf Not AdditionalParameters.AfterInstall Then
		BeginInstallFileSystemExtension(
			New NotifyDescription("AttachFileSystemExtensionWithPossibleInstallationOnEndExtensionInstallation",
			ThisObject, AdditionalParameters));
	Else
		ExecuteNotifyProcessing(AdditionalParameters.OnEndNotifyDescription, False);
	EndIf;

EndProcedure

Procedure AttachFileSystemExtensionWithPossibleInstallationOnEndSessionFileVariablesReading(Result,
	AdditionalParameters) Export

	ExecuteNotifyProcessing(AdditionalParameters.OnEndNotifyDescription, True);

EndProcedure

Procedure AttachFileSystemExtensionWithPossibleInstallationOnEndExtensionInstallation(AdditionalParameters) Export
	AttachFileSystemExtensionWithPossibleInstallation(AdditionalParameters.OnEndNotifyDescription,
		True);
EndProcedure

#EndRegion

#Region ApplicationParameters

Function SessionNumber() Export
	Return UT_ApplicationParameters["SessionNumber"];
EndFunction

#EndRegion

#Region SessionFileParametersReadingToApplicationParameters

Function SessionFileVariablesParameterName () Export	
	Return "FILE_VARIABLES";
EndFunction

// Sesstion file variables structure
//
// Return value:
//  Structure - Sesstion file variables
//  	*TempFilesDirectory - String -
//  	*UserDataWorkingDirectory - String -
Function SessionFileVariablesStructure() Export
	CurrentApplicationParameters=UT_ApplicationParameters;

	FileVariablesStructure=CurrentApplicationParameters[SessionFileVariablesParameterName()];
	If FileVariablesStructure = Undefined Then
		CurrentApplicationParameters[SessionFileVariablesParameterName()]=New Structure;
		FileVariablesStructure=CurrentApplicationParameters[SessionFileVariablesParameterName()];
	EndIf;

	Return FileVariablesStructure;
EndFunction

Procedure ReadMainSessionFileVariablesToApplicationParameters(OnEndNotifyDescription) Export
	NotifyAdditionalParameters=New Structure;
	NotifyAdditionalParameters.Insert("OnEndNotifyDescription", OnEndNotifyDescription);

	//1. Temp files directory
	BeginGettingTempFilesDir(
		New NotifyDescription("ReadMainSessionFileVariablesToApplicationParametersOnEndGettingTempFilesDir",
		ThisObject, NotifyAdditionalParameters));
EndProcedure

Procedure ReadMainSessionFileVariablesToApplicationParametersOnEndGettingTempFilesDir(DirectoryName,
	AdditionalParameters) Export
	FileVariablesStructure=SessionFileVariablesStructure();
	FileVariablesStructure.Insert("TempFilesDirectory", DirectoryName);

	BeginGettingUserDataWorkDir(
		New NotifyDescription("ReadMainSessionFileVariablesToApplicationParametersOnEndGettingUserDataWorkDir",
		ThisObject, AdditionalParameters));
EndProcedure

Procedure ReadMainSessionFileVariablesToApplicationParametersOnEndGettingUserDataWorkDir(DirectoryName,
	AdditionalParameters) Export
	FileVariablesStructure=SessionFileVariablesStructure();
	FileVariablesStructure.Insert("UserDataWorkingDirectory", DirectoryName);
	ExecuteNotifyProcessing(AdditionalParameters.OnEndNotifyDescription, True);
EndProcedure

#EndRegion

#Region ApplicationRun1С


// Description
// 
// Parameters:
// 	ClientType - Numeric - Run mode code
// 		1 - Designer
// 		2 - Thick client ordinary mode
// 		3 - Thick client managed application
// 		4 - Thin client
// 	User - String - Name of Database User , to run application 
// 	UnderUserRunMode - Boolean - Determines whether the user's password will be changed before launching. After the launch, the password will be returned back
// Returned value:
// 	
Function Run1CSession(ClientType, User, UnderUserRunMode = False,
	PauseBeforePasswordRestore = 20) Export
#If WebClient Then

#Else
		Directory1C = BinDir();

		LaunchString = Directory1C;

		LaunchFileExtension = "";
		If UT_CommonClientServer.IsWindows() Then
			LaunchFileExtension=".EXE";
		EndIf;

		If ClientType = 1 Then
			LaunchString = LaunchString + "1cv8" + LaunchFileExtension + " DESIGNER";
		ElsIf ClientType = 2 Then
			LaunchString = LaunchString + "1cv8" + LaunchFileExtension + " ENTERPRISE /RunModeOrdinaryApplication";
		ElsIf ClientType = 3 Then
			LaunchString = LaunchString + "1cv8" + LaunchFileExtension + " ENTERPRISE /RunModeManagedApplication";
		Else
			LaunchString = LaunchString + "1cv8c" + LaunchFileExtension + " ENTERPRISE";
		Endif;

		ConnectionString=InfoBaseConnectionString();
		ConnectionStringParametersArray = StrSplit(ConnectionString, ";");

		MatchOfConnectionStringParameters = New Structure;
		
		For Each StringParameterOfConnectionString In ConnectionStringParametersArray Do
			ParameterArray = StrSplit(StringParameterOfConnectionString, "=");

			If ParameterArray.Count() <> 2 Then
				Continue;
			Endif;

			Parameter = Lower(ParameterArray[0]);
			ParameterValue = ParameterArray[1];
			MatchOfConnectionStringParameters.Insert(Parameter, ParameterValue);
		EndDo;

		If MatchOfConnectionStringParameters.Property("file") Then
			LaunchString = LaunchString + " /F" + MatchOfConnectionStringParameters.File;
		ElsIf MatchOfConnectionStringParameters.Property("srvr") Then
			DataBasePath = UT_StringFunctionsClientServer.PathWithoutQuotes(MatchOfConnectionStringParameters.srvr) + "\"
				+ UT_StringFunctionsClientServer.PathWithoutQuotes(MatchOfConnectionStringParameters.ref);
			DataBasePath = UT_StringFunctionsClientServer.WrapInOuotationMarks(DataBasePath);
			LaunchString = LaunchString + " /S " + DataBasePath;
		ElsIf MatchOfConnectionStringParameters.Property("ws") Then
			LaunchString = LaunchString + " /WS " + MatchOfConnectionStringParameters.ws;
		Else
			Message(ConnectionString);
		EndIf;

		LaunchString = LaunchString + " /N""" + User + """";

		StoredIBUserPasswordData = Undefined;
		If UnderUserRunMode Then
			TempPassword = "qwerty123456";
			StoredIBUserPasswordData = UT_CommonServerCall.StoredIBUserPasswordData(
				User);
			UT_CommonServerCall.SetIBUserPassword(User, TempPassword);

			LaunchString = LaunchString + " /P" + TempPassword;
		EndIf;

		NotifyAdditionalParameters = New Structure;
		NotifyAdditionalParameters.Insert("UnderUserRunMode", UnderUserRunMode);
		NotifyAdditionalParameters.Insert("StoredIBUserPasswordData",StoredIBUserPasswordData);
		NotifyAdditionalParameters.Insert("User", User);
		NotifyAdditionalParameters.Insert("PauseBeforePasswordRestore", PauseBeforePasswordRestore);

		Try
			BeginRunningApplication(New NotifyDescription("Run1CSessionEndLaunch", ThisObject,
				NotifyAdditionalParameters), LaunchString);
		Except
			Message(BriefErrorDescription(ErrorInfo()));
		EndTry;
#EndIf
EndFunction

Procedure Run1CSessionEndLaunch(ReturnCode, AdditionalParameters) Export
	If Not AdditionalParameters.UnderUserRunMode Then
		Return;
	EndIf;

	LaunchTime = CurrentDate();
	While (CurrentDate() - LaunchTime) < AdditionalParameters.PauseBeforePasswordRestore Do
		UserInterruptProcessing();
	EndDo;

	UT_CommonServerCall.RestoreUserDataAfterUserSessionStart(
		AdditionalParameters.User, AdditionalParameters.StoredIBUserPasswordData);
EndProcedure

#EndRegion
Function InformationForSupportService() 
	InformationStructure = New Structure;
	InformationStructure.Insert("OptionSupplies", UT_CommonClientServer.DistributionType());
	InformationStructure.Insert("ToolsVersion", UT_CommonClientServer.Version());
	
	
	SystemInformation = New SystemInfo;
	
	InformationStructure.Insert("Platform", SystemInformation.AppVersion);
	InformationStructure.Insert("Client", UT_CommonClientServer.DescriptionOSForTechnicalSupport());
	#If WebClient Then
		InformationStructure.Insert("ClientType", "WebClient");
	#ElsIf ThinClient Then
		InformationStructure.Insert("ClientType", "ThinClient");
	#ElsIf MobileAppClient Then
		InformationStructure.Insert("ClientType", "MobileAppClient");
	#ElsIf ThickClientOrdinaryApplication Then
		InformationStructure.Insert("ClientType", "ThickClientOrdinaryApplication");
	#ElsIf ThickClientManagedApplication Then
		InformationStructure.Insert("ClientType", "ThickClientManagedApplication");
	#ElsIf MobileClient Then
		InformationStructure.Insert("ClientType", "MobileClient");
	#Else
		//@skip-check code-never-compilied
		InformationStructure.Insert("ClientType", "Undefined");
	#EndIf	
	
	UT_CommonServerCall.AddInformationForSupportOnTheServer(InformationStructure);
	
	Return InformationStructure;
EndFunction

Function InformationForSupportServiceAsString(Info, Prefix = "") 
	SupportAsString = "";
	
	For Each Iterator In Info Do
		If TypeOf(Iterator) = Type("KeyAndValue") Then
			If TypeOf(Iterator.Value) = Type("Structure") OR TypeOf(Iterator.Value) = Type("Array") Then
				SupportAsString = SupportAsString + InformationForSupportServiceAsString(Iterator.Value,
																				  ?(ValueIsFilled(Prefix),
																					Prefix + ".",
																					"") + Iterator.Key);
			Else
				SupportAsString = SupportAsString
								  + ?(ValueIsFilled(Prefix), Prefix + ".", "")
								  + Iterator.Key
								  + "="
								  + Iterator.Value
								  + ";"
								  + Chars.LF;
			EndIf;
		ElsIf TypeOf(Iterator) = Type("Structure") Then
			SupportAsString = SupportAsString + InformationForSupportServiceAsString(Iterator, Prefix);
		Else
			SupportAsString = SupportAsString
							  + ?(ValueIsFilled(Prefix), Prefix + ".", "")
							  + Iterator
							  + ";"
							  + Chars.LF;
		EndIf;
	EndDo;
		
	Return SupportAsString;
EndFunction
#EndRegion

Procedure BeginCleanToolsCacheAtClient(ОписаниеОповещенияОЗавершении = Неопределено) Export
	КаталогВспомогательныхБиблиотекИнструментов=КаталогВспомогательныхБиблиотекИнструментов();
	Если Не ValueIsFilled(КаталогВспомогательныхБиблиотекИнструментов) Тогда
		Return;
	КонецЕсли;
	//@skip-check empty-except-statement
	Try
		BeginDeletingFiles(,КаталогВспомогательныхБиблиотекИнструментов);
	Except
		
EndTry;
	
EndProcedure
// Каталог вспомогательных библиотек инструментов.
// 
// Возвращаемое значение:
//  Строка - Каталог вспомогательных библиотек инструментов
Function КаталогВспомогательныхБиблиотекИнструментов() Export
	FileVariablesStructure=SessionFileVariablesStructure();
	If Не FileVariablesStructure.Property("UserDataWorkingDirectory") Then
		Return "";
	EndIf;
	
	Return UT_CommonClientServer.КаталогВспомогательныхБиблиотекИнструментов(
	FileVariablesStructure.UserDataWorkingDirectory);
EndFunction