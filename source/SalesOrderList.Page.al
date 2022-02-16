pageextension 50212 "PPI Sales Order List" extends "Sales Order List"
{
    actions
    {
        addfirst(processing)
        {
            action("Download Selected SO")
            {
                Caption = 'Download Selected Sales Orders';
                ApplicationArea = All;
                Image = ExportFile;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    OutS: OutStream;
                    InS: InStream;
                    RecRef: RecordRef;
                    FldRef: FieldRef;
                    //FileManagement: Codeunit "File Management";
                    SalesHeader: Record "Sales Header";
                    DataCompression: Codeunit "Data Compression";
                    ZipFileName: Text[50];
                    PdfFileName: Text[50];
                begin
                    ZipFileName := 'SalesOrder_' + Format(CurrentDateTime) + '.zip';
                    DataCompression.CreateZipArchive();
                    SalesHeader.Reset;
                    CurrPage.SetSelectionFilter(SalesHeader);
                    if SalesHeader.FindSet() then
                        repeat
                            TempBlob.CreateOutStream(OutS);
                            RecRef.GetTable(SalesHeader);
                            FldRef := RecRef.Field(SalesHeader.FieldNo("No."));
                            FldRef.SetRange(SalesHeader."No.");
                            if RecRef.FindFirst() then begin
                                Report.SaveAs(Report::"Standard Sales - Order Conf.", '', ReportFormat::Pdf, OutS, RecRef);
                                TempBlob.CreateInStream(InS);
                                PdfFileName := Format(SalesHeader."Document Type") + ' ' + SalesHeader."No." + '.pdf';
                                DataCompression.AddEntry(InS, PdfFileName);
                                //FileManagement.BLOBExport(TempBlob, STRSUBSTNO('SalesOrder_%1.Pdf', Rec."No."), TRUE);
                            end
                        until SalesHeader.Next() = 0;
                    TempBlob.CreateOutStream(OutS);
                    DataCompression.SaveZipArchive(OutS);
                    TempBlob.CreateInStream(InS);
                    DownloadFromStream(InS, '', '', '', ZipFileName);
                end;
            }
        }
    }
}