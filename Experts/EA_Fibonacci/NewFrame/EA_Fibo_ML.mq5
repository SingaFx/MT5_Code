//+------------------------------------------------------------------+
//|                                              EA_Fibo_SE_bias.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <strategy_czj\strategyFibonacci\FibonacciML.mqh>
#include <Strategy\StrategiesList.mqh>

input double a1=0.1;
input double a2=0.1;
input double a3=0.1;
input double a4=0.1;
input double a5=0.1;

CStrategyList Manager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   double inp_alpha[5];
   inp_alpha[0]=a1;
   inp_alpha[1]=a2;
   inp_alpha[2]=a3;
   inp_alpha[3]=a4;
   inp_alpha[4]=a5;
   
   CFibonacciML *strategy= new CFibonacciML();
   strategy.ExpertName("CFibonacciML");
   strategy.ExpertMagic(111);
   strategy.Timeframe(_Period);
   strategy.ExpertSymbol(_Symbol);
   strategy.SetAlpha(inp_alpha);
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
