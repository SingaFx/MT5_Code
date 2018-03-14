//+------------------------------------------------------------------+
//|                                             RiskManager_Test.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include "RiskManager.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//void GetAccountInformation()
//  {
//   Print("账户信息");
//   HistorySelect(0,D'2030.01.01');
//   for(int i=0;i<HistoryDealsTotal();i++)
//     {
//      ulong ticket=HistoryDealGetTicket(i);
//      Print(i," ",
//            TimeToString(HistoryDealGetInteger(ticket,DEAL_TIME))," ",
//            ticket," ",
//            HistoryDealGetString(ticket,DEAL_SYMBOL)," ",
//            HistoryDealGetInteger(ticket,DEAL_TYPE)," ",
//            HistoryDealGetInteger(ticket,DEAL_ENTRY)," ",
//            HistoryDealGetDouble(ticket,DEAL_VOLUME)," ",
//            HistoryDealGetDouble(ticket,DEAL_PRICE)," ",
//            string(HistoryDealGetInteger(ticket,DEAL_ORDER))," ",
//            HistoryDealGetDouble(ticket,DEAL_COMMISSION)," ",
//            HistoryDealGetDouble(ticket,DEAL_SWAP), " ",
//            HistoryDealGetDouble(ticket,DEAL_PROFIT)," ",
//            HistoryDealGetInteger(ticket,DEAL_POSITION_ID));
//            
//     }
//  }
void test_risk_manager()
   {
    CRiskManager *rm=new CRiskManager();
    rm.RefreshInfor();
    rm.ToFile();
    delete rm;
   }
//+------------------------------------------------------------------+
