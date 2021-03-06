//+------------------------------------------------------------------+
//|                                             EA_BreakPointRSI.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyRSI\GridAddRSI.mqh>
#include <strategy_czj\strategyma\SimpleDoubleMA.mqh>

CStrategyList Manager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

   CGridAddRSIStrategy *rsi_s=new CGridAddRSIStrategy();
   rsi_s.ExpertName("RSI Grid add Strategy");
   rsi_s.ExpertMagic(2018011601);
   rsi_s.Timeframe(_Period);
   rsi_s.ExpertSymbol(_Symbol);
   rsi_s.SetEventDetect(_Symbol,_Period);
   rsi_s.InitStrategy();
   Manager.AddStrategy(rsi_s);
   
   CSimpleDoubleMA *ma_s=new CSimpleDoubleMA();;
   ma_s.ExpertName("Simple Double MA Strategy");
   ma_s.ExpertMagic(2018011602);
   ma_s.ExpertSymbol(_Symbol);
   ma_s.Timeframe(_Period);
   ma_s.SetEventDetect(_Symbol,_Period);
   ma_s.InitStrategy(200,24);
   Manager.AddStrategy(ma_s);
   
   
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
