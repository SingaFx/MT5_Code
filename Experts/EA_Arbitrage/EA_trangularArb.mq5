//+------------------------------------------------------------------+
//|                                                  EA_ArbTest2.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyTriangularArbitrage\CTriangularArbitrage.mqh>
CStrategyList Manager;
input string Inp_symbol_x="EURUSD";
input string Inp_symbol_y="GBPUSD";
input string Inp_symbol_xy="EURGBP";
input double Inp_lots=0.1;
input int Inp_dev_points=50;
input double Inp_win_per_lots=50;
input int ea_magic=8800;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   CTriangularArbitrage *arb = new CTriangularArbitrage();
   arb.ExpertMagic(ea_magic);
   arb.ExpertSymbol(_Symbol);
   arb.Timeframe(PERIOD_M1);
   arb.ExpertName("TriangularArbitrage"+string(ea_magic));
   arb.SetSymbolsInfor(Inp_symbol_x,Inp_symbol_y,Inp_symbol_xy,Inp_lots,Inp_dev_points,Inp_win_per_lots);
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
