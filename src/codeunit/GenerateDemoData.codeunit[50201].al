codeunit 50201 "Generate Demo Data"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        case rec."Parameter String" of
            'Customer':
                Create10Customers();
            'Order':
                Create10Orders();
            'Payment':
                CreateJnlJournalLine4Customers();
        end;

    end;

    procedure Create10Customers();
    var
        Customer: Record Customer;
        Counter: Integer;
        GenBusPostingGroup: List of [Text];
        CustomerPostingGroup: List of [Text];
        VatBusPostingGroup: List of [Text];
        PaymentTermsCode: List of [Text];
    begin
        GenBusPostingGroup.Add('DOMESTIC');
        GenBusPostingGroup.Add('EU');
        GenBusPostingGroup.Add('EXPORT');

        CustomerPostingGroup.Add('DOMESTIC');
        CustomerPostingGroup.Add('EU');
        CustomerPostingGroup.Add('FOREIGN');

        VatBusPostingGroup.Add('DOMESTIC');
        VatBusPostingGroup.Add('EU');
        VatBusPostingGroup.Add('EXPORT');

        PaymentTermsCode.Add('2 DAYS');
        PaymentTermsCode.Add('21 DAYS');
        PaymentTermsCode.Add('30 DAYS');
        PaymentTermsCode.Add('60 DAYS');
        PaymentTermsCode.Add('7 DAYS');

        For Counter := 1 to 10 do begin
            Customer.Init();
            Customer."No." := '';
            Customer.Insert(true);
            CallRestApi(Customer);

            //Randomize Customer's financial and grouping data
            Customer.Validate("Credit Limit (LCY)", Random(10000));
            Customer.Validate("Gen. Bus. Posting Group", GenBusPostingGroup.Get(Random(GenBusPostingGroup.Count)));
            Customer.Validate("Customer Posting Group", CustomerPostingGroup.Get(Random(CustomerPostingGroup.Count)));
            Customer.Validate("VAT Bus. Posting Group", VatBusPostingGroup.Get(Random(VatBusPostingGroup.Count)));
            Customer.Validate("Payment Terms Code", PaymentTermsCode.Get(Random(PaymentTermsCode.Count)));

            Customer.Modify(true);
        end;
    end;

    procedure CallRestApi(var pCustomer: Record Customer)
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        ResponseContent: HttpContent;
        ResponseString: Text;
        ResponseJson: JsonObject;
        JToken: JsonToken;
        lCountryCode: Code[20];
        lCountryName: Text;
        Country: Record "Country/Region";
        lPhoneNo: Text;
    begin
        HttpClient.Get('https://randomuser.me/api/', HttpResponseMessage);
        HttpResponseMessage.Content.ReadAs(ResponseString);

        ResponseJson.ReadFrom(ResponseString);

        ResponseJson.SelectToken('results[0].name.first', JToken);
        pCustomer.Validate(Name, JToken.AsValue().AsText());

        ResponseJson.SelectToken('results[0].name.last', JToken);
        pCustomer.Validate(Name, pCustomer.Name + ' ' + JToken.AsValue().AsText());

        ResponseJson.SelectToken('results[0].location.street.name', JToken);
        pCustomer.Validate(Address, JToken.AsValue().AsText());

        ResponseJson.SelectToken('results[0].location.street.number', JToken);
        pCustomer.Validate(Address, pCustomer.Address + ' ' + JToken.AsValue().AsText());

        ResponseJson.SelectToken('results[0].location.city', JToken);
        pCustomer.Validate(City, JToken.AsValue().AsText());

        ResponseJson.SelectToken('results[0].location.state', JToken);
        pCustomer.Validate(County, JToken.AsValue().AsText());

        ResponseJson.SelectToken('results[0].location.postcode', JToken);
        pCustomer.Validate("Post Code", JToken.AsValue().AsText());

        ResponseJson.SelectToken('results[0].location.country', JToken);
        lCountryName := JToken.AsValue().AsText();

        if not Country.Get(lCountryCode) then begin
            Country.Init();
            Country.Code := CopyStr(DelChr(lCountryCode, ' '), 1, 10);
            Country.Name := lCountryName;
            Country.Insert(true);
        end;

        pCustomer.Validate("Country/Region Code", lCountryCode);

        ResponseJson.SelectToken('results[0].email', JToken);
        pCustomer.Validate("E-Mail", JToken.AsValue().AsText());

        ResponseJson.SelectToken('results[0].phone', JToken);
        lPhoneNo := JToken.AsValue().AsText();
        lPhoneNo := DelChr(lPhoneNo, '=', DelChr(lPhoneNo, '=', '0123456789'));
        pCustomer.Validate("Phone No.", lPhoneNo);
    end;

    procedure Create10Orders();
    var
        SalesHeader: Record "Sales Header";
        Customer: Record Customer;
        RandomCustomerIdx: Integer;
        Counter: Integer;
        OrderCounter: Integer;
    begin
        for OrderCounter := 1 to 10 do begin
            SalesHeader.Init();
            SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
            SalesHeader."No." := '';
            SalesHeader.Insert(true);

            RandomCustomerIdx := Random(Customer.Count);
            Customer.FindFirst();
            Customer.Next(RandomCustomerIdx);

            SalesHeader.Validate("Sell-to Customer No.", Customer."No.");
            SalesHeader.Validate("Bill-to Customer No.", Customer."No.");

            SalesHeader.Validate("Document Date", CalcDate('-' + Format(Random(30)) + 'D', Today));
            SalesHeader.Validate("Posting Date", CalcDate('+' + Format(Random(30)) + 'D', SalesHeader."Document Date"));

            SalesHeader.Modify(true);

            For Counter := 1 to Random(5) do begin
                CreateSalesLine(SalesHeader, Counter);
            end;
        end;
    end;

    procedure CreateSalesLine(var pSalesHeader: Record "Sales Header"; idx: Integer);
    var
        SalesLine: Record "Sales Line";
        Item: Record Item;
        RandomItemIdx: Integer;
        Counter: Integer;
    begin
        SalesLine.Init();
        SalesLine."Document Type" := SalesLine."Document Type"::Order;
        SalesLine."Document No." := pSalesHeader."No.";
        SalesLine."Line No." := idx * 10000;
        SalesLine.Insert(true);

        RandomItemIdx := Random(Item.Count);
        Item.FindFirst();
        Item.Next(RandomItemIdx);

        SalesLine.Validate("Type", SalesLine.Type::Item);
        SalesLine.Validate("No.", Item."No.");
        SalesLine.Validate(Quantity, Random(10));
        SalesLine.Validate("Unit Price", Random(1500));
        SalesLine.Modify(true);
    end;


    procedure CreateJnlJournalLine4Customers()
    var
        Customer: Record Customer;
        GenJnlLine: Record "Gen. Journal Line";
        NextJnlLineNo: Integer;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        DocumentNo: Code[20];
    begin
        DocumentNo := NoSeriesMgt.TryGetNextNo('GJNL-PMT', Today);
        Customer.FindSet();
        repeat
            GenJnlLine.Reset();
            GenJnlLine.Setrange("Journal Template Name", 'PAYMENT');
            GenJnlLine.Setrange("Journal Batch Name", 'CASH');
            if GenJnlLine.FindLast() then
                NextJnlLineNo := GenJnlLine."Line No." + 10000
            else
                NextJnlLineNo := 10000;

            GenJnlLine.Init();
            GenJnlLine."Journal Template Name" := 'PAYMENT';
            GenJnlLine."Journal Batch Name" := 'CASH';
            GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;
            GenJnlLine."Document No." := DocumentNo;
            GenJnlLine."Line No." := NextJnlLineNo;
            GenJnlLine.Insert(true);

            GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::Customer);
            GenJnlLine.Validate("Account No.", Customer."No.");
            GenJnlLine.Validate("Posting Date", CalcDate('+' + Format(Random(30)) + 'D', Today));
            GenJnlLine.Validate("Document Date", CalcDate('+' + Format(Random(30)) + 'D', Today));
            GenJnlLine.Validate("Amount", -Random(10000));
            GenJnlLine.Validate("Payment Method Code", 'CASH');
            GenJnlLine.Validate("Bal. Account Type", GenJnlLine."Bal. Account Type"::"G/L Account");
            GenJnlLine.Validate("Bal. Account No.", '40100');
            GenJnlLine.Modify(true);
        until Customer.Next() = 0;
    end;

}