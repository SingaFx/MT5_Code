//+------------------------------------------------------------------+
//|                                                      EA_ABCD.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyRobot\Frame1\ZZAbcd.mqh>
#include <strategy_czj\common\strategy_common.mqh>

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CZZAbcd *s=new CZZAbcd();
   s.ExpertMagic(10);
   s.ExpertName("AB=CD");
   s.ExpertSymbol(_Symbol);
   s.Timeframe(_Period);
   s.InitZZ();
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
