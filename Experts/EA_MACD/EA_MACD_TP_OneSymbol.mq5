//+------------------------------------------------------------------+
//|                                         EA_MACD_TP_OneSymbol.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyMACD\strategyMacdTP.mqh>

CStrategyList Manager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CStrategyMacdTP *s = new CStrategyMacdTP();
   s.ExpertSymbol(_Symbol);
   s.Timeframe(_Period);
   s.ExpertName("MACD");
   s.ExpertMagic(111);
   s.SetMacdParameters();
   s.SetParametersTP(500,300);
   s.SetBaseLots();
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
