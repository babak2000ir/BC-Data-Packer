codeunit 50201 "Generate Customers"
{
    trigger OnRun()
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
        CustomerPostingGroup.Add('FORIEGN');

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
            Customer.Insert(true);
            CallRestApi(Customer);

            //Randomize Customer's financial and grouping data
            Customer.Validate("Credit Limit (LCY)", Random(10000));
            Customer.Validate("Gen. Bus. Posting Group", PaymentTermsCode.Get(Random(PaymentTermsCode.Count)));
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
        pCustomer.Validate("Country/Region Code", JToken.AsValue().AsText());

        ResponseJson.SelectToken('results[0].email', JToken);
        pCustomer.Validate("E-Mail", JToken.AsValue().AsText());

        ResponseJson.SelectToken('results[0].phone', JToken);
        pCustomer.Validate("Phone No.", JToken.AsValue().AsText());
    end;

}