//+------------------------------------------------------------------+
//|                                     EA_MultiGrid_Trend_Shock.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "一个品种对，设置两个网格，一个网格做趋势突破震荡行情止盈，一个网格做趋势回调止盈"
#include <Strategy\StrategiesList.mqh>
#include <strategy_czj\strategyGrid\GridOneSymbolGradeOut.mqh>
#include <strategy_czj\strategyGrid\GridTrendStrategy.mqh>


// 趋势行情的网格参数
input double Inp_base_lots_trend=0.01; // 趋势行情--基础手数
input int Inp_grid_trend=150; // 趋势行情--加仓点数
input int Inp_tp_per_lots_trend=20; // 趋势行情--每手止盈
input int Inp_tp_total_trend=100; // 趋势行情--总盈利
input long Inp_ea_magic_trend=1;

// 震荡回调行情的网格参数
input double Inp_base_lots_shock=0.1; // 震荡行情--基础手数
input int Inp_grid_add_shock=150; // 震荡行情--加仓点数
input int Inp_tp_per_lots_shock=5; // 震荡行情--每手止盈
input int Inp_tp_total_shock=2; // 震荡行情--总盈利
input int Inp_pos_num_shock=30;  // 震荡行情--仓位数控制
input LotsType Inp_lots_type_shock=ENUM_LOTS_EXP_NUM; // 震荡行情--手数序列类型
input long Inp_ea_magic_shock=2;

CStrategyList Manager;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   // 震荡行情的策略初始化
   CGridOneSymbolGradeOut *strategy=new CGridOneSymbolGradeOut();
   strategy.ExpertName("CGridOneSymbolGradeOut");
   strategy.ExpertMagic(Inp_ea_magic_shock);
   strategy.Timeframe(_Period);
   strategy.ExpertSymbol(_Symbol);
   strategy.Init(Inp_base_lots_shock,Inp_pos_num_shock,Inp_grid_add_shock,Inp_tp_per_lots_shock,Inp_tp_total_shock);
   strategy.SetLotsType(Inp_lots_type_shock);
   Manager.AddStrategy(strategy);
//   趋势行情的策略初始化
   CGridTrendStrategy *strategy2=new CGridTrendStrategy();
   strategy2.ExpertName("CGridTrendStrategy");
   strategy2.ExpertMagic(Inp_ea_magic_trend);
   strategy2.Timeframe(_Period);
   strategy2.ExpertSymbol(_Symbol);
   strategy2.Init(Inp_grid_trend,Inp_tp_per_lots_trend,Inp_base_lots_trend,Inp_tp_total_trend);
   Manager.AddStrategy(strategy2);
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
