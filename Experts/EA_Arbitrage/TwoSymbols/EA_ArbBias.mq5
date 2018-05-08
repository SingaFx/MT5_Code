//+------------------------------------------------------------------+
//|                                                      ArbBias.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <strategy_czj\strategyTwoArbitrage\TwoSymbolArbBias.mqh>
#include <Strategy\StrategiesList.mqh>

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   ArbBias *arb = new ArbBias();
   arb.ExpertMagic(1);
   arb.ExpertSymbol(_Symbol);
   arb.Timeframe(PERIOD_M1);
   arb.ExpertName("TriangularArbitrage");
  
   Manager.AddStrategy(arb);
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
