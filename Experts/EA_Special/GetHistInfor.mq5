//+------------------------------------------------------------------+
//|                                                 GetHistInfor.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyRSI\SimpleRSI.mqh>
#include <RiskManage_czj\RiskManager.mqh>
CStrategyList Manager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CSimpleRSIStrategy *rsi_s=new CSimpleRSIStrategy();
   rsi_s.ExpertName("RSI BreakPoints");
   rsi_s.ExpertMagic(2018012201);
   rsi_s.Timeframe(_Period);
   rsi_s.ExpertSymbol(_Symbol);
   rsi_s.SetEventDetect(_Symbol,_Period);
   Manager.AddStrategy(rsi_s);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   Manager.OnTick();
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---
    CRiskManager *rm=new CRiskManager();
    rm.RefreshInfor();
    rm.ToFile();
    delete rm;
//---
   return(ret);
  }
//+------------------------------------------------------------------+
