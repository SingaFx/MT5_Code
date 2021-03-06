//+------------------------------------------------------------------+
//|                                            EA_GridDoubleGrid.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyGrid\GridDouble.mqh>

input int Inp_points_add_major=50; // 主网格加仓点数
input int Inp_points_total_major=4500; // 主网格设置总趋势点
input int Inp_points_add_minor=200; // 次网格加仓点数
input int Inp_points_total_minor=3000; // 次网格设置总趋势点

//input double Inp_base_lots=0.01; // 基础手数

input uint Inp_magic=20181010;   // Magic ID
input ENUM_ORDER_TYPE_FILLING Inp_order_type=ORDER_FILLING_FOK;//FOK 指定额度执行， IOC使用市场最大量执行(微型账户使用)


CStrategyList Manager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CGridDouble *strategy=new CGridDouble();
   strategy.ExpertName("CGridDouble");
   strategy.ExpertMagic(Inp_magic);
   strategy.Timeframe(_Period);
   strategy.ExpertSymbol(_Symbol);
   strategy.Init(Inp_points_total_major,Inp_points_add_major,Inp_points_total_minor,Inp_points_add_minor);
  // strategy.SetTypeFilling(Inp_order_type);  // FOK 指定额度执行， IOC使用市场最大量执行(微型账户使用)
  // strategy.ReInitPositions();
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
