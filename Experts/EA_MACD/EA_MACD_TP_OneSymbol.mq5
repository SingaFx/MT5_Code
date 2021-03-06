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

input int InpTpPoints=500;
input int InpSlPoints=500;
input bool InpFilter=true; // 是否需要过滤一些不太好的背离
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
   s.SetParametersTP(InpTpPoints,InpSlPoints,InpFilter);
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
