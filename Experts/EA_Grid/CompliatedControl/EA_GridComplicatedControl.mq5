//+------------------------------------------------------------------+
//|                                    EA_GridComplicatedControl.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "复杂逻辑控制的网格策略"
#property description "针对28个品种"
#property description "风控模块,动态计算仓位风险,实时调整网格特质"
#property description "网格的开仓逻辑：正常开仓，信号开仓，对冲开仓，禁止开仓"
#property description "网格的平仓逻辑:"
#property description "    --检测所有品种的多空方向所有仓位是否满足止盈条件"
#property description "    --"

#include <strategy_czj\strategyGrid\ComplicatedControl\ComplicatedControlStrategy.mqh>
#include <Strategy\StrategiesList.mqh>
//
//input double Inp_base_lots=0.01; // 基础手数
//input GridLotsCalType Inp_lots_type=ENUM_GRID_LOTS_LINEAR;  // 手数类型
//input int Inp_exp_num=12;  // 设置指数类型手数控制的仓位数
//
//input int Inp_grid_gap=150; // 网格间距
//input double Inp_grid_tp_per_lots=600; // 每手止盈
//input double Inp_grid_tp_total=6;    // 总止盈
//
input uint Inp_magic=20181204;  // Magic
CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   CComplicatedControl *s=new CComplicatedControl();
   s.ExpertName("CComplicatedControl");
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