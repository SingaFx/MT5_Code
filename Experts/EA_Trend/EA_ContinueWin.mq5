//+------------------------------------------------------------------+
//|                                               EA_ContinueWin.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyTrend\ContinueWin.mqh>
input int Inp_ma_long_period=200;
input int Inp_ma_short_period=24;
input int Inp_win_points=200;
CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CContinueWin *s=new CContinueWin();
   s.ExpertName("Continue Win Strategy");
   s.ExpertMagic(11804100);
   s.Timeframe(_Period);
   s.ExpertSymbol(_Symbol);
   s.InitStrategy(Inp_ma_long_period,Inp_ma_short_period,Inp_win_points);
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
