//+------------------------------------------------------------------+
//|                                         PositionCloseLogical.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property description "平仓逻辑：针对28个品种对的当前仓位状态进行不同的逻辑设计"
#property description "    --case 1:所有品种所有仓位一起满足止盈的平仓方式"
#property description "    --case 2:单一品种多空仓位满足止盈且不增加最大币种风险的平仓方式"
#property description "    --case 3:检测最差品种对的分级出场"
#property description "          1.x为max(lot_buy-lots_sell)币种，y为min(lot_buy-lots_sell)币种,xy LongPosition 分级出场check"
#property description "          2.x为max(lot_buy-lots_sell)币种，y为min(lot_buy-lots_sell)币种,yx ShortPosition 分级出场check"
#property description "          3.x为max(lot_buy)币种，max(lots_sell)币种,xy LongPosition 分级出场check"
#property description "          4.x为max(lot_buy)币种，max(lots_sell)币种,yx ShortPosition 分级出场check"
#property description "          5:对风险最大方向的货币，其他货币同他进行匹配分级出场"
#property description "          6:同5，每次选取最大的风险币种方向，然后遍历其他比他小的币种进行匹配分级出场。。。待开发"
#property description "    --case 4:检测多空货币对的风险风向的分级出场"
#property description "          1.x为(lot_buy-lots_sell)>0.1币种，y为(lot_buy-lots_sell)<-0.1币种,xy LongPosition 分级出场check"
#property description "          1.x为(lot_buy-lots_sell)>0.1币种，y为(lot_buy-lots_sell)<-0.1币种,yx ShortPosition 分级出场check"


#include "ComplicatedControlStrategy.mqh"
//+------------------------------------------------------------------+
//|          case1同时检测所有仓位所有品种是否满足止盈条件                |
//+------------------------------------------------------------------+
void CComplicatedControl::CheckAllPositionClose(void)
  {
   if(profits_total>500) for(int i=0;i<28;i++) ClosePositionOnOneSymbolAt(i,"CloseAll");
  }
//+------------------------------------------------------------------+
//|              case2逐个检测单一品种所有仓位是否满足止盈条件            |
//+------------------------------------------------------------------+
void CComplicatedControl::CheckOneSymbolPositionClose(void)
  {
   for(int i=0;i<28;i++)
     {
      if(sym_profits[i]>100) // 该品种对的所有仓位盈利大于固定值
        {
         double risk_before_close=MathMax(MathAbs(currencies_risk[c_index[i][0]][0]-currencies_risk[c_index[i][0]][1]),MathAbs(currencies_risk[c_index[i][1]][0]-currencies_risk[c_index[i][1]][1]));
         double risk_after_close=MathMax(MathAbs(currencies_risk[c_index[i][0]][0]-currencies_risk[c_index[i][0]][1]+sym_risk[i][1]-sym_risk[i][0]),MathAbs(currencies_risk[c_index[i][1]][0]-currencies_risk[c_index[i][1]][1]-sym_risk[i][1]+sym_risk[i][0]));
         if(risk_after_close<risk_before_close) ClosePositionOnOneSymbolAt(i,"CloseOneSymbol");
        }
     }
  }
//+------------------------------------------------------------------+
//|      case3检测风险最大的两个币种对应风险是否满足分级出场止盈条件      |
//+------------------------------------------------------------------+
void CComplicatedControl::CheckWorstSymbolPartialPositionClose(void)
  {
   int index_long_max=0,index_short_max=0;   // 多头手数最大的货币索引，空头手数最大的货币索引
   double lots_long_max,lots_short_max;
   int index_delta_max=0,index_delta_min=0;  // 多空差值最大的货币索引,多空差值最小的货币索引
   double delta_lots_max,delta_lots_min;
   lots_long_max=currencies_risk[0][0];
   lots_short_max=currencies_risk[0][1];
   delta_lots_max=currencies_risk[0][0]-currencies_risk[0][1];
   delta_lots_min=currencies_risk[0][0]-currencies_risk[0][1];
   int risk_index;
   for(int i=1;i<8;i++)
     {
      if(currencies_risk[i][0]>lots_long_max) // 寻找多头手数最大的货币索引
        {
         lots_long_max=currencies_risk[i][0];
         index_long_max=i;
        }
      if(currencies_risk[i][1]>lots_short_max) // 寻找空头手数最大的货币索引
        {
         lots_short_max=currencies_risk[i][1];
         index_short_max=i;
        }
      if(currencies_risk[i][0]-currencies_risk[i][1]>delta_lots_max) // 寻找多-空手数最大的货币索引
        {
         delta_lots_max=currencies_risk[i][0]-currencies_risk[i][1];
         index_delta_max=i;
        }
      if(currencies_risk[i][0]-currencies_risk[i][1]<delta_lots_min) //寻找多-空手数最小的货币索引
        {
         delta_lots_min=currencies_risk[i][0]-currencies_risk[i][1];
         index_delta_min=i;
        }
     }
//--- 针对手数差异最大的币种，组成的品种对应风险方向进行分级出场条件判断；
   if(index_delta_max<index_delta_min)
     {
      risk_index=index_delta_max*(15-index_delta_max)/2+index_delta_min-index_delta_max-1;
      PartialClosePosition(risk_index,POSITION_TYPE_BUY,200,200,"PartialCloseLong--CHedgeMax");
     }
   else if(index_delta_max>index_delta_min)
     {
      risk_index=index_delta_min*(15-index_delta_min)/2+index_delta_max-index_delta_min-1;
      PartialClosePosition(risk_index,POSITION_TYPE_SELL,200,200,"PartialCloseShort--CHedgeMax");
     }
//--- 多头手数最多的x, 空头手数最多的y，组成的品种对应的方向做分级出场判断；
   if(index_long_max<index_short_max)
     {
      risk_index=index_long_max*(15-index_long_max)/2+index_short_max-index_long_max-1;
      PartialClosePosition(risk_index,POSITION_TYPE_BUY,200,200,"PartialCloseLong--CMax");
     }
   else if(index_long_max>index_short_max)
     {
      risk_index=index_short_max*(15-index_short_max)/2+index_long_max-index_short_max-1;
      PartialClosePosition(risk_index,POSITION_TYPE_SELL,200,200,"PartialCloseShort--CMax");
     }
//---
   if(currencies_risk[index_long_max][0]>currencies_risk[index_short_max][1])
     {
      for(int i=0;i<8;i++)
        {
         if(i<index_long_max)
           {
            risk_index=i*(15-i)/2+index_long_max-i-1;
            PartialClosePosition(risk_index,POSITION_TYPE_SELL,200,200,"PartialCloseShort--CWorstCurrencyToOthers");
           }
         else if(i>index_long_max)
                {
                 risk_index=index_long_max*(15-index_long_max)/2+i-index_long_max-1;
                 PartialClosePosition(risk_index,POSITION_TYPE_BUY,200,200,"PartialCloseLong--CWorstCurrencyToOthers");
                }
        }
     }
   else if(currencies_risk[index_long_max][0]<currencies_risk[index_short_max][1])
          {
           for(int i=0;i<8;i++)
           {
            if(i<index_short_max)
              {
               risk_index=i*(15-i)/2+index_short_max-i-1;
               PartialClosePosition(risk_index,POSITION_TYPE_BUY,200,200,"PartialCloseLong--CWorstCurrencyToOthers");
              }
            else if(i>index_short_max)
                   {
                    risk_index=index_short_max*(15-index_short_max)/2+i-index_short_max-1;
                    PartialClosePosition(risk_index,POSITION_TYPE_SELL,200,200,"PartialCloseShort--CWorstCurrencyToOthers");
                   }
           }
          }
  }
//+------------------------------------------------------------------+
//|       case 4:检测多空货币对的风险风向的分级出场                |
//+------------------------------------------------------------------+
void CComplicatedControl::CheckRiskSymbolsPartialPositionClose(void)
  {
   CArrayLong arr_long_index;
   CArrayLong arr_short_index;
   CArrayLong arr_long_index2;
   CArrayLong arr_short_index2;
//    设定货币多空阈值：用于后续确定可以进行品种分级出场的货币
   for(int i=0;i<8;i++)
     {
      //if(currencies_risk[i][0]>1) arr_long_index.Add(i);
      //if(currencies_risk[i][1]>1) arr_short_index.Add(i);
      if(currencies_risk[i][0]-currencies_risk[i][1]>0.1) arr_long_index2.Add(i);
      if(currencies_risk[i][0]-currencies_risk[i][1]<-0.1)  arr_short_index2.Add(i);
     }
//---
   for(int i=0;i<arr_long_index2.Total();i++)
     {
      for(int j=0;j<arr_short_index2.Total();j++)
        {
         int risk_index;
         if(arr_long_index2[i]<arr_short_index2[j])
           {
            risk_index=arr_long_index2[i]*(15-arr_long_index2[i])/2+arr_short_index2[j]-arr_long_index2[i]-1;
            PartialClosePosition(risk_index,POSITION_TYPE_BUY,200,200,"PartialCloseLong--CHedgeThread");
           }
         else if(arr_long_index2[i]>arr_short_index2[j])
           {
            risk_index=arr_short_index2[j]*(15-arr_short_index2[j])/2+arr_long_index2[i]-arr_short_index2[j]-1;
            PartialClosePosition(risk_index,POSITION_TYPE_SELL,200,200,"PartialCloseShort--CHedgeThread");
           }
        }
     }
// 将多空货币对组合后，进行分级出场操作
   //for(int i=0;i<arr_long_index.Total();i++)
   //  {
   //   for(int j=0;j<arr_short_index.Total();j++)
   //     {
   //      int risk_index;
   //      if(arr_long_index[i]<arr_short_index[j])
   //        {
   //         risk_index=arr_long_index[i]*(15-arr_long_index[i])/2+arr_short_index[j]-arr_long_index[i]-1;
   //         PartialClosePosition(risk_index,POSITION_TYPE_BUY,200,200);
   //        }
   //      else if(arr_long_index[i]>arr_short_index[j])
   //        {
   //         risk_index=arr_short_index[j]*(15-arr_short_index[j])/2+arr_long_index[i]-arr_short_index[j]-1;
   //         PartialClosePosition(risk_index,POSITION_TYPE_SELL,200,200);
   //        }
   //     }
   //  }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicatedControl::PartialClosePosition(int index,ENUM_POSITION_TYPE p_type,double profits_total_,double profits_per_lots_,string comment="")
  {
   CArrayLong *p_id;
   CArrayLong *p_level;
   string close_flag;
   if(p_type==POSITION_TYPE_BUY)
     {
      p_id=&long_pos_id[index];
      p_level=&long_pos_level[index];
     }
   else
     {
      p_id=&short_pos_id[index];
      p_level=&short_pos_level[index];
     }

   if(p_id.Total()==0) return;

//    获取需要进行分级出场的仓位情况的统计信息
   double sum_l=0,sum_p=0,temp_p;
   CArrayLong arr_index=new CArrayLong();
   for(int i=0;i<p_id.Total();i++)
     {
      PositionSelectByTicket(p_id.At(i));
      temp_p=PositionGetDouble(POSITION_PROFIT);
      if(i==0 || temp_p>0)
        {
         sum_l+=PositionGetDouble(POSITION_VOLUME);
         sum_p+=temp_p;
         arr_index.Add(i);
        }
     }
// 判断是否满足分级出场条件，进行操作
   if(sum_p>profits_total_ || sum_p/sum_l>profits_per_lots_)
     {
      for(int i=0;i<arr_index.Total();i++)
        {
         Trade.PositionClose(p_id.At(arr_index.At(i)),comment);
        }
      for(int i=arr_index.Total()-1;i>=0;i--)
        {
         p_id.Delete(arr_index.At(i));
         p_level.Delete(arr_index.At(i));
        }
     }
  }