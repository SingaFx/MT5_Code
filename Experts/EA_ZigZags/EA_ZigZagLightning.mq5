//+------------------------------------------------------------------+
//|                                           EA_ZigZagLightning.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <strategy_czj\strategyZigZag\ZigZagLightning.mqh>
#include <Strategy\StrategiesList.mqh>

input int Inp_EA_Magic = 118062101;

CStrategyList Manager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CZigZagLightning *strategy= new CZigZagLightning();
   strategy.ExpertName("CZigZagLightning");
   strategy.ExpertMagic(Inp_EA_Magic);
   strategy.Timeframe(_Period);
   strategy.ExpertSymbol(_Symbol);
   Manager.AddStrategy(strategy);
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
