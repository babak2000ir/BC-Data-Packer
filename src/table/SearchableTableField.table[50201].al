table 50201 "Searchable Table Field"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Table ID"; Integer)
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(10; "Field ID"; Integer)
        {
            DataClassification = ToBeClassified;

            trigger OnLookup()
            var
                SearchableHeader: Record "Searchable Table";
                FieldLookup: page "Fields Lookup";
                FieldRecord: Record Field;
            begin
                if SearchableHeader.Get(rec."Table ID") then begin
                    FieldRecord.Reset();
                    FieldRecord.SetRange(TableNo, SearchableHeader."Table ID");
                    FieldLookup.SetTableView(FieldRecord);
                    FieldLookup.LookupMode(true);
                    if FieldLookup.RunModal() = Action::LookupOK then begin
                        FieldLookup.GetRecord(FieldRecord);
                        "Field ID" := FieldRecord."No.";
                        "Field Name" := FieldRecord.FieldName;
                    end;
                end;
            end;

            trigger OnValidate()
            begin
                if "Field ID" = 0 then
                    "Field Name" := '';
            end;
        }
        field(11; "Field Name"; Text[30])
        {
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(21; Active; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Table ID", "Field ID")
        {
            Clustered = true;
        }
    }
}