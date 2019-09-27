//+------------------------------------------------------------------+
//|                                                 EA_FiboTrend.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <strategy_czj\strategyFibonacci\FiboTrend.mqh>
#include <Strategy\StrategiesList.mqh>
input int Inp_EA_Magic = 118062001;

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CFiboTrend *strategy= new CFiboTrend();
   strategy.ExpertName("CFiboTrend");
   strategy.ExpertMagic(Inp_EA_Magic);
   strategy.Timeframe(_Period);
   strategy.ExpertSymbol(_Symbol);
   strategy.Init();
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
