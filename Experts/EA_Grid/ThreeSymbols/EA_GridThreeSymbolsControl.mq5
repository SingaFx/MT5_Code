//+------------------------------------------------------------------+
//|                                   EA_GridThreeSymbolsControl.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyGrid\GridThreeSymbolsControl.mqh>
input string Inp_c1="EUR";
input string Inp_c2="GBP";
input string Inp_c3="JPY";
input bool  Inp_hedge_enable=true;

CStrategyList Manager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  //---
   CGridThreeSymbolsControl *strategy=new CGridThreeSymbolsControl();
   strategy.ExpertName("CGridThreeSymbolsControl");
   strategy.ExpertMagic(2018090401);
   strategy.Timeframe(_Period);
   strategy.ExpertSymbol(_Symbol);
   strategy.SetCurrencies(Inp_c1,Inp_c2,Inp_c3);
   strategy.SetHedgeAllowed(Inp_hedge_enable);
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

