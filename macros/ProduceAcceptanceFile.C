
#include<TCanvas.h>
#include<TGraphErrors.h>
#include<TH1.h>
#include<TH3.h>

void ProduceAcceptanceFile( TString fname = "../eventAnalysis/ConvMiddleQuarterCurrent/MergedOutput.root" )
{

  TFile *f = new TFile(fname, "READ");

  TH1D *trackerTop = (TH1D*)f->Get("LumiTracker/hTrackerTop_Acceptance");
  TH1D *trackerBot = (TH1D*)f->Get("LumiTracker/hTrackerBot_Acceptance");
  TH1D *trackerCoinc = (TH1D*)f->Get("LumiTracker/hTrackerCoincidence_Acceptance");
  TH1D *calTop = (TH1D*)f->Get("LumiSpecCAL/hCALTop_Acceptance");
  TH1D *calBot = (TH1D*)f->Get("LumiSpecCAL/hCALBot_Acceptance");
  TH1D *calCoinc = (TH1D*)f->Get("LumiSpecCAL/hCALCoincidence_Acceptance");

  vector<TH1D*> histoSet = {trackerTop, trackerBot, trackerCoinc, calTop, calBot, calCoinc};

  TH1D *genPhotons = (TH1D*)f->Get("hGenPhoton_E");
 
  TFile *fout = new TFile("acceptanceFile.root","RECREATE");

  for( auto h : histoSet ) {
    h->Divide( genPhotons );
    h->SetDirectory(0);
    h->GetYaxis()->SetTitle("Acceptance");

    h->Write();
  }

  // In terms of scattered electron energy

  TH1D *trackerTop_SE = new TH1D("trackerTop_SE", ";Electron energy E (GeV);PS acceptance", trackerTop->GetNbinsX(), trackerTop->GetXaxis()->GetXmin(), trackerTop->GetXaxis()->GetXmax() );
  TH1D *trackerCoinc_SE = new TH1D("trackerCoinc_SE", ";Electron energy E (GeV);PS acceptance", trackerTop->GetNbinsX(), trackerTop->GetXaxis()->GetXmin(), trackerTop->GetXaxis()->GetXmax() );
  trackerTop_SE->SetMarkerStyle(20);
  trackerCoinc_SE->SetMarkerStyle(20);

  for( int bin = 1; bin <= trackerTop->GetNbinsX(); bin++ ) {
    
    double SE_Energy = 18 - trackerTop->GetXaxis()->GetBinCenter(bin);
    if( trackerTop->GetBinContent(bin) > 0.0001 ) {
      trackerTop_SE->Fill( SE_Energy, trackerTop->GetBinContent(bin) );
      trackerTop_SE->SetBinError(bin, 0.00001);
    }

    if( trackerCoinc->GetBinContent(bin) > 0.0001 ) {
      trackerCoinc_SE->Fill( SE_Energy, trackerCoinc->GetBinContent(bin) );
      trackerCoinc_SE->SetBinError(bin, 0.00001);
    }
  }

  //trackerTop_SE->Draw("hist p");
  trackerCoinc_SE->Draw("hist p");

  trackerTop_SE->Write();
  trackerCoinc_SE->Write();

}
