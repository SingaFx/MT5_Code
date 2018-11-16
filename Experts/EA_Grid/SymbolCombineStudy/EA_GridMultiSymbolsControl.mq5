//+------------------------------------------------------------------+
//|                                   EA_GridMultiSymbolsControl.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyGrid\GridMultiSymbols.mqh>

CStrategyList Manager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CGridMultiSymbolsControl *strategy=new CGridMultiSymbolsControl();
   strategy.ExpertName("CGridMultiSymbolsControl");
   strategy.ExpertMagic(2018090401);
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

