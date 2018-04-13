//+------------------------------------------------------------------+
//|                                                      EA_ArbN.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyMultiArbitrage\MultiArbitrage.mqh>
CStrategyList Manager;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   string Inp_symbols_1[]={"XAUUSD","USDJPY"};
   string Inp_symbols_2[]={"EURUSD","USDCHF"};
   int Inp_win_points=50;
   int Inp_tau=;
   double Inp_delta
   
   
   CMultiArbitrage *arb =new CMultiArbitrage();
   arb.InitStrategy(Inp_symbols_1,Inp_win_points
   arb.ExpertMagic(111);
   arb.ExpertSymbol(_Symbol);
   arb.Timeframe(_Period);
   arb.ExpertName("Arbitrage"+string(111));
   Manager.AddStrategy(arb);
   
   
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
