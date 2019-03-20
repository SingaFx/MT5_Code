//+------------------------------------------------------------------+
//|                                              EA_MACD_Reverse.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <strategy_czj\strategyMACD\strategyMacdReverse.mqh>
#include <Strategy\StrategiesList.mqh>

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CMACDReverse *s = new CMACDReverse();
   s.ExpertName("MACD Reverse");
   s.ExpertSymbol(_Symbol);
   s.Timeframe(_Period);
   s.ExpertMagic(11);
   s.SetBaseLots();
   s.SetMacdParameters();
   s.SetParametersNewPosition(4,500);
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
