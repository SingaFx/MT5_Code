//+------------------------------------------------------------------+
//|                              FibonacciOneLevelIndexParameter.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "Fibonacci 回调入场趋势策略"
#property description "参数采用定义好的参数组合，直接指定parameter_index(0~23)可以对应参数组合"

#include <strategy_czj\Fibonacci.mqh>
#include <Strategy\StrategiesList.mqh>
#include <FibonacciParameters.mqh>

input int parameter_index=0;// 参数组合对应的索引值
input double open_lots1=0.01; //开仓手数
input int Ea_Magic=118062601; // MAGIC

 int period_search_mode=FP_bar_search[parameter_index];   //搜素模式的大周期
 int range_period=FP_bar_max[parameter_index]; //模式的最大数据长度
 int range_point=FP_range_min[parameter_index]; //短周期模式的最小点数差
 double open_level1=FP_open[parameter_index]; //开仓点
 double tp_level1=FP_tp[parameter_index]; //止盈平仓点
 double sl_level1=FP_sl[parameter_index]; //止损平仓点
 
CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   FibonacciRatioStrategy *strategy1;
   strategy1=new FibonacciRatioStrategy();
   strategy1.ExpertMagic(Ea_Magic);
   strategy1.Timeframe(_Period);
   strategy1.ExpertSymbol(_Symbol);
   strategy1.ExpertName("Fibonacci Ratio Strategy");
   strategy1.SetPatternParameter(period_search_mode,range_period,range_point);
   strategy1.SetOpenRatio(open_level1);
   strategy1.SetCloseRatio(tp_level1,sl_level1);
   strategy1.SetLots(open_lots1);
   strategy1.SetEventDetect(_Symbol,_Period);
   
   Manager.AddStrategy(strategy1);
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
