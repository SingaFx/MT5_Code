//+------------------------------------------------------------------+
//|                                                  EA_HedgeRSI.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <strategy_czj\strategyHedge\PairHedgeRSI.mqh>
#include <Strategy\StrategiesList.mqh>

input string Inp_Sym_y="EURUSD";
input SymbolRelation Inp_sr=RELATION_POSITIVE;
input int InpRsiPeriod=3;
input double InpRsiUp=60;
input double InpRsiDown=40;
input int InpTpPerLots=50;

//input int Inp_tp_points=40;

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CPairHedgeRSI *s = new CPairHedgeRSI();
   s.ExpertName("CPairHedgeRSI");
   s.ExpertMagic(111);
   s.ExpertSymbol(_Symbol);
   s.Timeframe(_Period);
   s.SetBasicParameters(_Symbol,Inp_Sym_y,Inp_sr);
   s.SetRSI(InpRsiPeriod,InpRsiUp,InpRsiDown);
   s.SetTP(InpTpPerLots);
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
