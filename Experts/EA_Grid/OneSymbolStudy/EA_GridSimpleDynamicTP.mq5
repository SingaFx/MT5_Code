//+------------------------------------------------------------------+
//|                                       EA_GridSimpleDynamicTP.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyGrid\GridSimpleDynamicTP.mqh>

input int Inp_points_add=300; // 网格加仓点数
input int Inp_points_win=600; // 网格出场止盈点数
input double Inp_base_lots=0.01; // 基础手数
input GridLotsCalType  Inp_lots_type=ENUM_GRID_LOTS_EXP_NUM;// 手数类型
input GridWinType Inp_win_type=ENUM_GRID_WIN_LAST; // 设置止盈点位的方式
input uint Inp_magic=20181010;   // Magic ID
input int Inp_pos_max=10;   // 手数类型--第n个仓位为1手，参数n的值
input ENUM_ORDER_TYPE_FILLING Inp_order_type=ORDER_FILLING_FOK;//FOK 指定额度执行， IOC使用市场最大量执行(微型账户使用)

input double Inp_tp_ratio=3/2;   // 设置轻仓位的止盈点同重仓位止盈点的比例
input int Inp_unbalance=5; // 判断重轻仓的不均衡度

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CGridSimpleDynamicTP *strategy=new CGridSimpleDynamicTP();
   strategy.ExpertName("CGridSimpleDynamicTP");
   strategy.ExpertMagic(Inp_magic);
   strategy.Timeframe(_Period);
   strategy.ExpertSymbol(_Symbol);
   strategy.Init(Inp_points_add,Inp_points_win,Inp_base_lots,Inp_lots_type,Inp_win_type,Inp_pos_max);
   strategy.SetDynamicParameter(Inp_tp_ratio,Inp_unbalance);
   strategy.SetTypeFilling(Inp_order_type);  // FOK 指定额度执行， IOC使用市场最大量执行(微型账户使用)
   strategy.ReInitPositions();
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
