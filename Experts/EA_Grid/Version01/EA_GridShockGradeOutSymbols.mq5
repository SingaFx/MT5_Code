//+------------------------------------------------------------------+
//|                                  EA_GridShockGradeOutSymbols.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property description "震荡网格策略--分级出场"
#property description "检测仓位较重的方向:"
#property description "    仓位小于三级,检测所有仓位的每手止盈和总止盈是否满足条件出场"
#property description "    仓位大于等于三级,检测最后两个仓位和最早仓位的每手止盈和总止盈是否满足条件出场"
#property description "参数设置1--手数序列:基础手数,序列类型,指数仓位控制数"
#property description "参数设置2--网格参数:网格间距,每手止盈,总止盈"
#include <strategy_czj\strategyGrid\Strategies\GridShockStrategyGradeOut.mqh>
#include <Strategy\StrategiesList.mqh>

input string Inp_symbols_str="EURGBP,USDJPY,AUDNZD,AUDJPY";  // 品种
input string Inp_base_lots_str="0.01,0.01,0.01,0.01"; // 基础手数
input GridLotsCalType Inp_lots_type=ENUM_GRID_LOTS_LINEAR;  // 手数类型
input string Inp_exp_num_str="12,12,12,12";  // 设置指数类型手数控制的仓位数

input string Inp_grid_gap_str="150,150,150,150"; // 网格间距
input string Inp_grid_tp_per_lots_str="100,100,100,100"; // 每手止盈
input string Inp_grid_tp_total_str="60,60,60,60";    // 总止盈

input uint Inp_magic=20181207;  // Magic

CStrategyList Manager;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   string arr_sym[];
   string arr_b_lots[];
   string arr_exp_num[];
   string arr_grid_gap[];
   string arr_tp_per_lots[];
   string arr_tp_total[];
   int num=StringSplit(Inp_symbols_str,StringGetCharacter(",",0),arr_sym);
   StringSplit(Inp_base_lots_str,StringGetCharacter(",",0),arr_b_lots);
   StringSplit(Inp_exp_num_str,StringGetCharacter(",",0),arr_exp_num);
   StringSplit(Inp_grid_gap_str,StringGetCharacter(",",0),arr_grid_gap);
   StringSplit(Inp_grid_tp_per_lots_str,StringGetCharacter(",",0),arr_tp_per_lots);
   StringSplit(Inp_grid_tp_total_str,StringGetCharacter(",",0),arr_tp_total);
   for(int i=0;i<num;i++)
     {
      CGridShockStrategyGradeOut *s=new CGridShockStrategyGradeOut();
      s.ExpertName("CGridShockStrategyGradeOut-"+arr_sym[i]);
      s.ExpertMagic(Inp_magic+i);
      s.ExpertSymbol(arr_sym[i]);
      s.Timeframe(_Period);
      s.SetLotsParameter(StringToDouble(arr_b_lots[i]),Inp_lots_type,StringToInteger(arr_exp_num[i]));
      s.SetGridParameter(StringToInteger(arr_grid_gap[i]),StringToDouble(arr_tp_per_lots[i]),StringToDouble(arr_tp_total[i]));
      Manager.AddStrategy(s);
     }
//---

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

