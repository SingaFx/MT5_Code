//+------------------------------------------------------------------+
//|                                              EA_Fibo_SE_bias.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "Fibonacci回调点位+Bias信号增强"
#property description "进行对品种同时回测"
#include <strategy_czj\strategyFibonacci\FibonacciSimple.mqh>
#include <Strategy\StrategiesList.mqh>

input int Inp_num_recognize=12;
input int Inp_num_max=4;
input int Inp_point_range=500;
input double Inp_ratio_open=0.382;
input double Inp_ratip_tp=0.618;
input double Inp_ratio_sl=-1.0;
input double Inp_base_lots=0.01;
input ENUM_TIMEFRAMES Inp_bias_tf=PERIOD_M5; 
input int Inp_bias_period=24;
input int Inp_num_cal_bias=100;
input double Inp_prob_bias=0.2;
input double Inp_lots_coef=5.0;
input string Inp_symbol_enable="1,1,1,1,1,1,1";
input ulong ea_magic=71807100;
CStrategyList Manager;
string symbols[7]={"AUDUSD","EURUSD","GBPUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   string symbol_selected[];
   int num_symbols=StringSplit(Inp_symbol_enable,StringGetCharacter(",",0),symbol_selected);
   CFibonacciSimple *strategy[7];
   for(int i=0;i<num_symbols;i++)
     {
      strategy[i] = new CFibonacciSimple();
      strategy[i].ExpertName("FibonacciSimpleSeBias"+string(symbols[i]));
      strategy[i].ExpertMagic(71807100+i);
      strategy[i].Timeframe(_Period);
      strategy[i].ExpertSymbol(symbols[i]);
      strategy[i].SetBasicParameters(Inp_num_recognize,Inp_num_max,Inp_point_range,Inp_ratio_open,Inp_ratip_tp,Inp_ratio_sl,Inp_base_lots);
      strategy[i].SetBiasParameters(Inp_bias_tf,Inp_bias_period,Inp_num_cal_bias,Inp_prob_bias,Inp_lots_coef);
      Manager.AddStrategy(strategy[i]);
     }
   
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
