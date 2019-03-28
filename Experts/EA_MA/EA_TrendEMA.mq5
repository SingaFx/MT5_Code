//+------------------------------------------------------------------+
//|                                                  EA_TrendEMA.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyMA\TrendEMA.mqh>
input int InpEmaHighLow=150;
input int InpEmaClose=50;
input int InpWilliamLong=100;
input int InpWilliamShort=10;

CStrategyList Manager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CTrendEMA *ma_s=new CTrendEMA();
   ma_s.ExpertName("CTrendEMA");
   ma_s.ExpertMagic(2018011601);
   ma_s.Timeframe(_Period);
   ma_s.ExpertSymbol(_Symbol);

   ma_s.InitHandles(InpEmaClose,InpEmaHighLow,InpEmaHighLow,InpWilliamLong,InpWilliamShort);
   Manager.AddStrategy(ma_s);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+-------------------------------------            -----------------------------+
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