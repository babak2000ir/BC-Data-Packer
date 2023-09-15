page 50201 "Search. Tab. Fields List Part"
{
    PageType = ListPart;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "Searchable Table Field";
    AutoSplitKey = true;
    Caption = 'Searchable Tables Fields List';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Table ID"; rec."Table ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Field ID"; rec."Field ID")
                {
                    ApplicationArea = All;
                }
                field("Field Name"; rec."Field Name")
                {
                    ApplicationArea = All;
                }
                field(Active; rec.Active)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}