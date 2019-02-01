//+------------------------------------------------------------------+
//|                                                      EA_CC_3.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <strategy_czj\strategyGrid\ComplicatedControl\CCStrategyThree.mqh>
#include <Strategy\StrategiesList.mqh>
input uint Inp_magic=20181204;  // Magic
CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CCStrategyThree *s=new CCStrategyThree();
   s.ExpertName("CCStrategyThree");
   s.ExpertMagic(Inp_magic);
   s.ExpertSymbol(_Symbol);
   s.Timeframe(_Period);
   //s.SetLotsParameter(Inp_base_lots,Inp_lots_type,Inp_exp_num);
   //s.SetGridParameter(Inp_grid_gap,Inp_grid_tp_per_lots,Inp_grid_tp_total);
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