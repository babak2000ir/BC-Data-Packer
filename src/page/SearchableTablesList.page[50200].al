page 50200 "Searchable Tables List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Searchable Table";

    layout
    {
        area(Content)
        {
            repeater(SelectATable)
            {
                Caption = 'Select a Table';
                field("Table ID"; rec."Table ID")
                {
                    ApplicationArea = All;
                }
                field("Table Name"; rec."Table Name")
                {
                    ApplicationArea = All;
                }
                field("AI Guide"; rec."AI Guide")
                {
                    ApplicationArea = All;
                }
                field(Active; rec.Active)
                {
                    ApplicationArea = All;
                }
            }
            part("Search. Tab. Fields List Part"; "Search. Tab. Fields List Part")
            {
                SubPageLink = "Table ID" = field("Table ID");
                ApplicationArea = all;
            }
        }
    }
}