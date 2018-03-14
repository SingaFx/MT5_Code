//+------------------------------------------------------------------+
//|                                                  EA_ArbTest2.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyTriangularArbitrage\CTriangularArbCurrency.mqh>
CStrategyList Manager;
input string Inp_currency_x="EUR";
input string Inp_currency_y="GBP";
input double Inp_lots=0.1;
input int Inp_dev_points=50;
input double Inp_win_per_lots=50;
input int ea_magic=1800;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   CTriangularArbCurrency *arb = new CTriangularArbCurrency();
   arb.ExpertMagic(ea_magic);
   //arb.ExpertSymbol(_Symbol);
   arb.Timeframe(PERIOD_M1);
   arb.ExpertName("TriangularArbCurrency"+string(ea_magic));
   arb.SetSymbolsInfor(Inp_currency_x,Inp_currency_y,Inp_lots,Inp_dev_points,Inp_win_per_lots);
   Manager.AddStrategy(arb);
      
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
      
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
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+
