//+------------------------------------------------------------------+
//|                                                   LogicClose.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "CCOpenCloseLogic.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCOpenCloseLogic::CheckAllPositionClose(double p_total,double p_per_lots)
  {
   if(pos_risk_state.GetTotalProfits()>p_total || pos_risk_state.GetTotalProfitsPerLots()>p_per_lots)
     {
      Print("平仓操作:CASE-1 所有仓位总盈利>",p_total," 或每手盈利>",p_per_lots);
      for(int i=0;i<28;i++) ClosePositionOnOneSymbolAt(i,"CloseAll");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCOpenCloseLogic::CheckOneSymbolPositionClose(int index_s,double p_total,double p_per_lots)
  {
   if(pos_risk_state.GetMaxRiskChangeAfterCloseSymbolAt(index_s)<0)
     {
      if(pos_risk_state.GetSymbolProfitsAt(index_s)>p_total || pos_risk_state.GetSymbolProfitsPerLotsAt(index_s)>p_per_lots) // 该品种对的所有仓位盈利大于固定值,且平仓不增加两个货币的最大风险
        {
         Print("平仓操作:CASE-2 单个品种所有仓位大于",p_total,",且不增加仓位风险--",SYMBOLS_28[index_s]);
         ClosePositionOnOneSymbolAt(index_s,"CloseOneSymbol");
        }
     }
  }
//+------------------------------------------------------------------+
//|      case3检测风险最大的两个币种对应风险是否满足分级出场止盈条件 |
//+------------------------------------------------------------------+
void CCOpenCloseLogic::CheckWorstSymbolPartialPositionClose(double p_total,double p_per_lots)
  {
//--- 针对手数差异最大的币种，组成的品种对应风险方向进行分级出场条件判断；
   PartialClosePosition(pos_risk_state.GetIndexCurrencyDeltaMax(),pos_risk_state.GetIndexCurrencyDeltaMin(),p_total,p_per_lots,"PartialClose");
//--- 多头手数最多的x, 空头手数最多的y，组成的品种对应的方向做分级出场判断；
   PartialClosePosition(pos_risk_state.GetIndexCurrencyLongMax(),pos_risk_state.GetIndexCurrencyShortMax(),p_total,p_per_lots,"PartialClose");
//---
  }
//+------------------------------------------------------------------+
//|       case 4:检测多空货币对的风险方向的分级出场                  |
//+------------------------------------------------------------------+
void CCOpenCloseLogic::CheckRiskSymbolsPartialPositionClose(double p_total,double p_per_lots)
  {
   CArrayInt arr_long_index;
   CArrayInt arr_short_index;
//    设定货币多空阈值：用于后续确定可以进行品种分级出场的货币
   for(int i=0;i<8;i++)
     {
      if(pos_risk_state.GetCurrencyDeltaRiskAt(i)>0.1) arr_long_index.Add(i);
      if(pos_risk_state.GetCurrencyDeltaRiskAt(i)<-0.1) arr_short_index.Add(i);
     }
//---
   for(int i=0;i<arr_long_index.Total();i++)
     {
      for(int j=0;j<arr_short_index.Total();j++)
        {
         PartialClosePosition(arr_long_index.At(i),arr_short_index.At(j),p_total,p_per_lots,"CASE4");
        }
     }
   delete &arr_long_index;
   delete &arr_short_index;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCOpenCloseLogic::CheckOneSymbolCombinePositionClose(void)
  {
   for(int i=0;i<28;i++)
     {
      switch(pos_risk_state.GetRiskTypeSTC(i))
        {
         case ENUM_RISKSTC_DOUBLE_RISK :
            if(pos_risk_state.GetSymbolDeltaRiskAt(i)>0)
              {
               CloseAllShortFirstLongPosition(i,200,200,"CloseCombine");
              }
            else
              {
               CloseAllLongFirstShortPosition(i,200,200,"CloseCombine");
              }
            break;
         default:
            break;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCOpenCloseLogic::PartialClosePosition(int index_c_long,int index_c_short,double profits_total_,double profits_per_lots_,string comment="")
  {
   if(index_c_long==index_c_short) return;
   int index;
   if(index_c_long<index_c_short)
     {
      index=index_c_long*(15-index_c_long)/2+index_c_short-index_c_long-1;
      PartialClosePosition(index,profits_total_,profits_per_lots_,POSITION_TYPE_BUY,comment);
     }
   else
     {
      index=index_c_short*(15-index_c_short)/2+index_c_long-index_c_short-1;
      PartialClosePosition(index,profits_total_,profits_per_lots_,POSITION_TYPE_SELL,comment);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCOpenCloseLogic::PartialClosePosition(int index,double profits_total_,double profits_per_lots_,ENUM_POSITION_TYPE p_type,string comment="")
  {
   double partial_profits,partial_lots;
   CArrayInt partial_i_pos;
   if(p_type==POSITION_TYPE_BUY)
     {
      pos_risk_state.GetPartialLongPosition(index,partial_i_pos,partial_profits,partial_lots);
      if(partial_i_pos.Total()==0) return;
      if(partial_profits>profits_total_ || partial_profits/partial_lots>profits_per_lots_) CloseLongPositionAt(index,partial_i_pos,"PartialClose");
     }
   else
     {
      pos_risk_state.GetPartialShortPosition(index,partial_i_pos,partial_profits,partial_lots);
      if(partial_i_pos.Total()==0) return;
      if(partial_profits>profits_total_ || partial_profits/partial_lots>profits_per_lots_) CloseShortPositionAt(index,partial_i_pos,"PartialClose");
     }
   delete &partial_i_pos;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCOpenCloseLogic::CloseAllLongFirstShortPosition(int index_s,double profits_total_,double profits_per_lots_,string comment="")
  {
   if(pos_risk_state.GetSymbolAllLongFirstShortProfitsAt(index_s)>profits_total_ || pos_risk_state.GetSymbolAllLongFirstShortProfitsPerLotsAt(index_s)>profits_per_lots_)
     {
      CloseLongPositionAt(index_s,comment);
      CloseShortPositionAt(index_s,0,comment);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCOpenCloseLogic::CloseAllShortFirstLongPosition(int index_s,double profits_total_,double profits_per_lots_,string comment="")
  {
   if(pos_risk_state.GetSymbolAllShortFirstLongProfitsAt(index_s)>profits_total_ || pos_risk_state.GetSymbolAllLongFirstShortProfitsPerLotsAt(index_s)>profits_per_lots_)
     {
      CloseShortPositionAt(index_s,comment);
      CloseLongPositionAt(index_s,0,comment);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCOpenCloseLogic::CheckSmallPositionTP(void)
  {
   for(int i=0;i<28;i++)
     {
      if(DistanceLatestPriceToLastBuyPrice(i)<-150*4 && pos_risk_state.GetSymbolDeltaRiskAt(i)<0 && pos_risk_state.GetSymbolLongProfitsAt(i)>0)
        {
         CloseLongPositionAt(i,"SmallLongPosTP");
        }
      if(DistanceLatestPriceToLastSellPrice(i)<-150*4 && pos_risk_state.GetSymbolDeltaRiskAt(i)>0 && pos_risk_state.GetSymbolShortProfitsAt(i)>0)
        {
         CloseShortPositionAt(i,"SmallShortPosTP");
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCOpenCloseLogic::CloseSmallLongPositionOpenNewLong(int i_s,int level)
  {
   CloseLongPositionAt(i_s,"small tp");
   OpenLongPositionAt(i_s,level,"OpenNewBig");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCOpenCloseLogic::CloseSmallShortPositionOpenNewShort(int i_s,int level)
  {
   CloseShortPositionAt(i_s,"CloseSmallTP");
   OpenShortPositionAt(i_s,level,"OpenNewBig");
  }
//+------------------------------------------------------------------+
