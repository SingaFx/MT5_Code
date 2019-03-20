//+------------------------------------------------------------------+
//|                                                   EA_TickArb.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <strategy_czj\strategyTicks\TickStrategy.mqh>
#include <Strategy\StrategiesList.mqh>

input string Inp_Sym_y="EURUSD";
input SymbolRelation Inp_sr=RELATION_POSITIVE;
input int Inp_tp_points=40;

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CTickStrategy *s = new CTickStrategy();
   s.ExpertName("TickStrategy");
   s.ExpertMagic(111);
   s.ExpertSymbol(_Symbol);
   s.Timeframe(_Period);
   s.SetSymbolX(_Symbol);
   s.SetSymbolY(Inp_Sym_y);
   s.SetSymbolRelation(Inp_sr);
   s.SetTP(Inp_tp_points);
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
