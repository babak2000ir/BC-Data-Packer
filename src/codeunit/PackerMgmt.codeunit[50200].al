codeunit 50200 "Packer Mgmt."
{
    procedure GetTableInfo(pTableId: Integer): Text
    var
        lResult: Text;
    begin
        _GetTableInfo(pTableId).WriteTo(lResult);
        exit(lResult);
    end;

    procedure GetTablesInfo(): Text
    var
        lResult: Text;
    begin
        _GetTablesInfo().WriteTo(lResult);
        exit(lResult);
    end;

    local procedure _GetTableInfo(pTableId: Integer): JsonObject;
    var
        lJOResponseHeader: JsonObject;
        lJAKeyFields: JsonArray;
        lJAFields: JsonArray;
    begin
        GetFieldsData(pTableId, lJAKeyFields, lJAFields);
        lJOResponseHeader.Add('keyFields', lJAKeyFields);
        lJOResponseHeader.Add('fields', lJAFields);

        exit(lJOResponseHeader);
    end;

    local procedure _GetTablesInfo(): JsonArray
    var
        SearchableTables: Record "Searchable Table";
        lJOResponse: JsonObject;
        lJAResponse: JsonArray;
        TableRec: Record AllObjWithCaption;
    begin
        SearchableTables.SetAutoCalcFields("Table Name");
        SearchableTables.RESET();
        if SearchableTables.FINDSET() then
            repeat
                if TableRec.Get(TableRec."Object Type"::Table, SearchableTables."Table ID") then begin
                    lJOResponse.Add('tableCaption', TableRec."Object Caption");
                    //lJOResponse.Add('fieldInfo', _GetTableInfo(SearchableTables."Table ID"));
                    lJOResponse.Add('records', _GetTableRecords(SearchableTables."Table ID"));
                    lJAResponse.Add(lJOResponse);
                    Clear(lJOResponse);
                end;
            until SearchableTables.NEXT() = 0;
        exit(lJAResponse);
    end;


    local procedure GetEntityJson(var pRecRef: RecordRef): JsonObject
    var
        lFields: Record "Field";
        lJOResponse: JsonObject;
        lFieldRef: FieldRef;
        SearchableTableField: Record "Searchable Table Field";
    begin
        lFields.RESET();
        lFields.SETRANGE(TableNo, pRecRef.Number);
        if lFields.FINDSET() then
            repeat
                if SearchableTableField.Get(pRecRef.Number, lFields."No.") then
                    if lFields.Enabled and (lFields.ObsoleteState = lFields.ObsoleteState::No) then begin
                        lFieldRef := pRecRef.Field(lFields."No.");
                        lJOResponse.Add(lFieldRef.Caption, format(lFieldRef.Value(), 0, 9));
                    end;
            until lFields.NEXT() = 0;
        exit(lJOResponse);
    end;

    local procedure GetFieldsData(pTableId: Integer; pJAKeyFields: JsonArray; pJAFields: JsonArray)
    var
        lFields: Record "Field";
        lJOPart: JsonObject;
    begin
        lFields.RESET();
        lFields.SETRANGE(TableNo, pTableId);
        if lFields.FINDSET() then
            repeat
                if lFields.Enabled and (lFields.ObsoleteState = lFields.ObsoleteState::No) then begin
                    Clear(lJOPart);
                    lJOPart.Add('fieldName', lFields.FieldName);
                    lJOPart.Add('fieldType', lFields."Type Name");
                    if lFields.IsPartOfPrimaryKey then
                        pJAKeyFields.Add(lJOPart)
                    else
                        pJAFields.Add(lJOPart);
                end;
            until lFields.NEXT() = 0;
    end;

    local procedure _GetTableRecords(pTableId: Integer): JsonArray
    var
        lRecRef: RecordRef;
        lJOResponse: JsonObject;
        lJAResponse: JsonArray;
    begin
        lRecRef.OPEN(pTableId);
        if lRecRef.FINDSET() then
            repeat
                lJOResponse := GetEntityJson(lRecRef);
                lJAResponse.Add(lJOResponse);
                Clear(lJOResponse);
            until lRecRef.NEXT() = 0;
        lRecRef.CLOSE();
        exit(lJAResponse);
    end;

}

