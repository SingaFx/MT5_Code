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
//   计算每个品种的多空手数，计算每个币种的多空手数，计算每个品种的盈利，计算所有品种的盈利
   for(int i=0;i<8;i++)
     {
      currencies_risk[i][0]=0;
      currencies_risk[i][1]=0;
     }
   profits_total=0;
   for(int i=0;i<28;i++)
     {
      sym_risk[i][0]=0;
      sym_risk[i][1]=0;
      sym_profits[i]=0;
      for(int j=0;j<long_pos_id[i].Total();j++)
        {
         PositionSelectByTicket(long_pos_id[i].At(j));
         sym_risk[i][0]+=PositionGetDouble(POSITION_VOLUME);   // 品种多头手数累加
         currencies_risk[c_index[i][0]][0]+=PositionGetDouble(POSITION_VOLUME);  // 品种对应的前面币种多头手数累加
         currencies_risk[c_index[i][1]][1]+=PositionGetDouble(POSITION_VOLUME);  // 品种对应的后面币种空头手数累加
         profits_total+=PositionGetDouble(POSITION_PROFIT);
         sym_profits[i]+=PositionGetDouble(POSITION_PROFIT);
        }
      for(int j=0;j<short_pos_id[i].Total();j++)
        {
         PositionSelectByTicket(short_pos_id[i].At(j));
         sym_risk[i][1]+=PositionGetDouble(POSITION_VOLUME);   // 品种空头手数累加
         currencies_risk[c_index[i][0]][1]+=PositionGetDouble(POSITION_VOLUME);  // 品种对应的前面币种空头手数累加
         currencies_risk[c_index[i][1]][0]+=PositionGetDouble(POSITION_VOLUME);  // 品种对应的后面币种多头手数累加 
         profits_total+=PositionGetDouble(POSITION_PROFIT);
         sym_profits[i]+=PositionGetDouble(POSITION_PROFIT);
        }
     }
  }
void CComplicatedControl::RefreshOpenState(void)
   {
    for(int i=0;i<28;i++)
      {
       open_long_state[i]=OPEN_STATE_NORMAL;
       open_short_state[i]=OPEN_STATE_NORMAL;
//       第一个币种多头风险，第二个币种空头风险=>空头开仓设置为激励状态
       if(currencies_risk[c_index[i][0]][0]-currencies_risk[c_index[i][0]][1]>1&&currencies_risk[c_index[i][1]][1]-currencies_risk[c_index[i][1]][0]>1)
         {
          open_short_state[i]=OPEN_STATE_EXCITATION;
         }
//       第一个币种空头风险，第二个币种多头风险=>多头开仓设置为激励状态
       if(currencies_risk[c_index[i][0]][1]-currencies_risk[c_index[i][0]][0]>1&&currencies_risk[c_index[i][1]][0]-currencies_risk[c_index[i][1]][1]>1)
         {
          open_long_state[i]=OPEN_STATE_EXCITATION;
         }       
      }
   }
//+------------------------------------------------------------------+
