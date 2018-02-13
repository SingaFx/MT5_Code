//+------------------------------------------------------------------+
//|                                              EA_GridAddTrend.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyTrend\GridAddTrend.mqh>
input int Int_points=100;
input double Int_win_ratio=2.0;
input double Int_init_lots=0.01;

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CGridAddTrend *s=new CGridAddTrend();
   s.ExpertName("Trend add Strategy");
   s.ExpertMagic(2018013101);
   s.Timeframe(_Period);
   s.ExpertSymbol(_Symbol);
   s.SetEventDetect(_Symbol,_Period);
   s.InitStrategy(Int_points,Int_win_ratio,Int_init_lots);
   Manager.AddStrategy(s);
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
