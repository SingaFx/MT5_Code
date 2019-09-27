//+------------------------------------------------------------------+
//|                                                        EA_R1.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <strategy_czj\strategyTemp\R1.mqh>
#include <Strategy\StrategiesList.mqh>

input int InpTP=500;
input int InpSL=500;
input int InpRsiUp=70;
input int InpRsiDown=30;
input int InpBandRange=300;


CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CR1 *s=new CR1();
   s.ExpertSymbol(_Symbol);
   s.Timeframe(_Period);
   s.ExpertName("CR1");
   s.ExpertMagic(2018012201);
   s.SetBandParameter(20,2,InpBandRange);
   s.SetRsiParameter(14,InpRsiUp,InpRsiDown);
   s.SetTpAndSl(InpTP,InpSL);
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
