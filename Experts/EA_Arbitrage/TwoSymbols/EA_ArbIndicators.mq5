//+------------------------------------------------------------------+
//|                                                      ArbBias.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <strategy_czj\strategyTwoArbitrage\TwoSymbolArbitrage.mqh>
#include <Strategy\StrategiesList.mqh>

input string Inp_major_symbol="XAUUSD";
input string Inp_minor_symbol="USDJPY";
input CointergrationCalType Inp_Coin_type=ENUM_COINTERGRATION_TYPE_MULTIPLY;
input IndicatorCalType Inp_Ind_type=ENUM_INDICATOR_TYPE_ORIGIN;
input int Inp_Ind_Cal_period=1440; // 指标计算的数量
input bool Inp_Used_Prob=true; // 是否使用概率计算
input int Inp_Prob_period=1440;// 概率统计的数量
input double Inp_Ind_open_short=0.995;//做空的指标触发值
input double Inp_Ind_open_long=0.005;//做多的指标触发值
input double Inp_base_lots=0.1;
input double Inp_Ind_close_short=0.005;//平空的指标触发值
input double Inp_Ind_close_long=0.995;//平多的指标触发值
input int   Inp_TP=500;
input bool  Inp_Use_Levels_Close=true;
input int   Inp_close_level_num=5;
input double Inp_days_out=1000;
input uint  Inp_magic=1;


CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CTwoSymbolArbitrage *arb = new CTwoSymbolArbitrage();
   arb.SetIndicatorParameter(Inp_major_symbol,Inp_minor_symbol,Inp_Coin_type,Inp_Ind_type,Inp_Ind_Cal_period,Inp_Used_Prob,Inp_Prob_period);
   arb.SetOpenCloseParameter(Inp_Ind_open_long,Inp_Ind_open_short,Inp_Ind_close_long,Inp_Ind_close_short,Inp_TP,Inp_days_out,Inp_base_lots);
   arb.SetCloseLevels(Inp_Use_Levels_Close,Inp_close_level_num);
   arb.ExpertMagic(1);
   arb.ExpertSymbol(_Symbol);
   arb.Timeframe(PERIOD_M1);
   arb.ExpertName("TwoSymbolArbitrage");
  
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
