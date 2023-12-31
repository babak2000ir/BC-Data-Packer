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
        lJAFields: JsonArray;
    begin
        GetFieldsData(pTableId, lJAFields);
        //lJOResponseHeader.Add('keyFields', lJAKeyFields);
        lJOResponseHeader.Add('fields', lJAFields);

        exit(lJOResponseHeader);
    end;

    local procedure _GetTablesInfo(): JsonArray
    var
        SearchableTables: Record "Searchable Table";
        lJOResponse: JsonObject;
        lJAResponse: JsonArray;
        TableRec: Record AllObjWithCaption;
        lJAFields: JsonArray;
        SearchableAIGuide: Record "Searchable AI Guide";
        lJOAIGuide: JsonObject;
        lJAAIGuide: JsonArray;
    begin
        SearchableAIGuide.Reset();
        if SearchableAIGuide.FindSet() then
            repeat
                case SearchableAIGuide."AI Guide Type" of
                    SearchableAIGuide."AI Guide Type"::System:
                        lJAAIGuide.Add(SearchableAIGuide.Content);
                //SearchableAIGuide."AI Guide Type"::Sample:
                //    lJAAIGuide.Add(SearchableAIGuide."AI Guide");
                end;
            until SearchableAIGuide.NEXT() = 0;

        lJOAIGuide.Add('systemGuide', lJAAIGuide);
        lJAResponse.Add(lJOAIGuide);

        SearchableTables.SetAutoCalcFields("Table Name");
        SearchableTables.RESET();
        SearchableTables.SETRANGE(active, true);
        if SearchableTables.FINDSET() then
            repeat
                if TableRec.Get(TableRec."Object Type"::Table, SearchableTables."Table ID") then begin
                    lJOResponse.Add('tableCaption', TableRec."Object Caption");
                    if SearchableTables."AI Guide" <> '' then
                        lJOResponse.Add('tableAIGuide', SearchableTables."AI Guide");
                    //lJOResponse.Add('fieldInfo', _GetTableInfo(SearchableTables."Table ID"));
                    GetFieldsData(SearchableTables."Table ID", lJAFields);
                    lJOResponse.Add('tableFields', lJAFields);
                    lJOResponse.Add('tableRecords', _GetTableRecords(SearchableTables."Table ID"));
                    lJAResponse.Add(lJOResponse);
                    Clear(lJOResponse);
                    Clear(lJAFields);
                end;
            until SearchableTables.NEXT() = 0;
        exit(lJAResponse);
    end;


    local procedure GetEntityJson(var pRecRef: RecordRef): JsonArray
    var
        lFields: Record "Field";
        lJOResponse: JsonObject;
        lJAResponse: JsonArray;
        lFieldRef: FieldRef;
        SearchableTableField: Record "Searchable Table Field";
    begin
        lFields.RESET();
        lFields.SETRANGE(TableNo, pRecRef.Number);
        if lFields.FINDSET() then
            repeat
                Clear(lJOResponse);
                if SearchableTableField.Get(pRecRef.Number, lFields."No.") and SearchableTableField.Active then
                    if lFields.Enabled and (lFields.ObsoleteState = lFields.ObsoleteState::No) then begin
                        lFieldRef := pRecRef.Field(lFields."No.");

                        if lFieldRef.Class = lFieldRef.Class::FlowField then
                            lFieldRef.CalcField();

                        if lFieldRef.Type = lFieldRef.Type::Option then
                            lJOResponse.Add(lFieldRef.Caption, lFieldRef.GetEnumValueCaption(lFieldRef.Value()))
                        else
                            lJOResponse.Add(lFieldRef.Caption, format(lFieldRef.Value(), 0, 9));
                        lJAResponse.Add(lJOResponse);
                    end;
            until lFields.NEXT() = 0;
        exit(lJAResponse);
    end;

    local procedure GetFieldsData(pTableId: Integer; var pJAFields: JsonArray)
    var
        lFields: Record "Field";
        lJOPart: JsonObject;
        SearchableTableField: Record "Searchable Table Field";
    begin
        lFields.RESET();
        lFields.SETRANGE(TableNo, pTableId);
        if lFields.FINDSET() then
            repeat
                if SearchableTableField.Get(pTableId, lFields."No.") and SearchableTableField.Active then
                    if lFields.Enabled and (lFields.ObsoleteState = lFields.ObsoleteState::No) then begin
                        Clear(lJOPart);
                        lJOPart.Add('fieldCaption', lFields."Field Caption");
                        if SearchableTableField."AI Guide" <> '' then
                            lJOPart.Add('fieldAIGuide', SearchableTableField."AI Guide");
                        //if lFields.IsPartOfPrimaryKey then
                        //    pJAKeyFields.Add(lJOPart)
                        //else
                        pJAFields.Add(lJOPart);
                    end;
            until lFields.NEXT() = 0;
    end;

    local procedure _GetTableRecords(pTableId: Integer): JsonArray
    var
        lRecRef: RecordRef;
        lJAResponse: JsonArray;
    begin
        lRecRef.OPEN(pTableId);
        if lRecRef.FINDSET() then
            repeat
                lJAResponse.Add(GetEntityJson(lRecRef));
            until lRecRef.NEXT() = 0;
        lRecRef.CLOSE();
        exit(lJAResponse);
    end;

}

