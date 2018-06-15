//+------------------------------------------------------------------+
//|                                        EA_PinBarStrategyTest.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <strategy_czj\strategyPinBar\PinBar.mqh>
#include <Strategy\StrategiesList.mqh>
CStrategyList Manager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CPinBarStrategy *pinbar= new CPinBarStrategy();
   pinbar.ExpertName("PinBar");
   pinbar.ExpertMagic(4180615);
   pinbar.Timeframe(_Period);
   pinbar.ExpertSymbol(_Symbol);
   Manager.AddStrategy(pinbar);
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
