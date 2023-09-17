table 50202 "Searchable AI Guide"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(10; "AI Guide Type"; Option)
        {
            OptionMembers = System,Sample;
        }
        field(11; "Content"; Text[500])
        {
            DataClassification = ToBeClassified;
        }
        field(12; "Response"; Text[1024])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}