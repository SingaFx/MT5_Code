//+------------------------------------------------------------------+
//|                                              FibonacciZigZag.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <strategy_czj\strategyFibonacci\FibonacciZigZag.mqh>
#include <Strategy\StrategiesList.mqh>

input double Inp_Fibo_Open=0.382;
input double Inp_Fibo_TP=0.618;
input double Inp_Fibo_SL=-0.618;
input double Inp_lots=0.01;
input int Inp_EA_Magic = 118062001;

CStrategyList Manager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CFibonacciZigZag *strategy= new CFibonacciZigZag(Inp_Fibo_Open,Inp_Fibo_TP,Inp_Fibo_SL,Inp_lots);
   strategy.ExpertName("FibonacciZigZag");
   strategy.ExpertMagic(Inp_EA_Magic);
   strategy.Timeframe(_Period);
   strategy.ExpertSymbol(_Symbol);
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
