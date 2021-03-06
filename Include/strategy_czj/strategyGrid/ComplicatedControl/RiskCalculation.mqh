//+------------------------------------------------------------------+
//|                                               RiskCaculation.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property description "仓位状态：收益和风险的计算模块"
#property description "    --所有品种多空方向总盈利"
#property description "    --每个品种的多空方向总盈利"
#property description "    --每个品种多头和空头的手数"
#property description "    --每个货币多头和空头的手数"

#include "ComplicatedControlStrategy.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicatedControl::RefreshRiskInfor(void)
  {
   //Print("Out:",long_pos_id[0].At(0),long_pos_id[1].At(0),long_pos_id[2].At(0),long_pos_id[3].At(0),long_pos_id[4].At(0),long_pos_id[5].At(0),long_pos_id[6].At(0));
   pos_risk_state.RefreshState(long_pos_id,short_pos_id);
   pos_risk_state.RiskSort();
  }
void CComplicatedControl::RefreshOpenState(void)
   {

   }
//+------------------------------------------------------------------+
