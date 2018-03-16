//+------------------------------------------------------------------+
//|                                                 test_account.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <RiskManage_czj\RiskManager.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   //GetAccountInformation();
   CRiskManager *rm=new CRiskManager();
    rm.RefreshInfor();
    rm.ToFile();
    delete rm;
  }
//+------------------------------------------------------------------+
