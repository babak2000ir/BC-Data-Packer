page 50202 "Searchable AI Guide"
{
    PageType = ListPart;
    UsageCategory = Lists;
    ApplicationArea = All;
    SourceTable = "Searchable AI Guide";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {

                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field("AI Guide Type"; Rec."AI Guide Type")
                {
                    ToolTip = 'Specifies the value of the AI Guide Type field.';
                }
                field("Content / Question"; Rec.Content)
                {
                    ToolTip = 'Specifies the value of the Content field.';
                }
                field("Sample Response"; Rec.Response)
                {
                    ToolTip = 'Specifies the value of the Response field.';
                }
            }
        }
    }
}