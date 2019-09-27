//+------------------------------------------------------------------+
//|                                                         Test.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyRobot\StrategyMLMA.mqh>

input double a1=1;
input double a2=1;
input double a3=1;
input double a4=1;
input double a5=1;
input double a6=1;
input double a7=1;

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   double alpha[7];
   alpha[0]=a1;
   alpha[1]=a2;
   alpha[2]=a3;
   alpha[3]=a4;
   alpha[4]=a5;
   alpha[5]=a6;
   alpha[6]=a7;
  
   CStrategyMLMA *strategy=new CStrategyMLMA();
   strategy.ExpertName("CStrategyMLMA");
   strategy.ExpertMagic(2018090401);
   strategy.Timeframe(_Period);
   strategy.ExpertSymbol(_Symbol);
   strategy.Init();
   strategy.SetAlpha(alpha);
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
