//+------------------------------------------------------------------+
//|                                                    LogicOpen.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "CCOpenCloseLogic.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCOpenCloseLogic::CheckNormGridPositionOpen(void)
  {
   for(int i=0;i<28;i++)
     {
      if(!pos_risk_state.IsSymbolOpenLong(i)||pos_risk_state.GetSymbolDeltaRiskAt(i)<0)
        {
         NormGridOpenLongAt(i);
        }
      if(!pos_risk_state.IsSymbolOpenShort(i)||pos_risk_state.GetSymbolDeltaRiskAt(i)>0)
        {
         NormGridOpenShortAt(i);
        }
      //if(pos_risk_state.GetSymbolLongRiskAt(i)<0.1||pos_risk_state.GetSymbolShortRiskAt(i)>pos_risk_state.GetSymbolLongRiskAt(i)) NormGridOpenLongAt(i,150,"OpenNorm");
      //if(pos_risk_state.GetSymbolShortRiskAt(i)<0.1||pos_risk_state.GetSymbolShortRiskAt(i)<pos_risk_state.GetSymbolLongRiskAt(i)) NormGridOpenShortAt(i,150,"OpenNorm");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCOpenCloseLogic::CheckTrendGridPositionOpen(void)
  {
   for(int i=0;i<28;i++)
     {
      if(pos_risk_state.IsSymbolWorstCase(i))
        {
         if(pos_risk_state.GetSymbolDeltaRiskAt(i)>0)
           {
            TrendGridOpenShortAt(i,300);
           }
         if(pos_risk_state.GetSymbolDeltaRiskAt(i)<0)
           {
            TrendGridOpenLongAt(i,300);
           }
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CCOpenCloseLogic::NormGridOpenLongAt(int index,double grid_gap=150,string comment=" ")
  {
   if(!pos_risk_state.IsSymbolOpenLong(index)) return OpenLongPositionAt(index,1,comment);
   else if(DistanceLatestPriceToLastBuyPrice(index)>grid_gap) return OpenLongPositionAt(index,pos_risk_state.LastLongLevelAt(index)+1,comment);
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CCOpenCloseLogic::NormGridOpenShortAt(int index,double grid_gap=150,string comment=" ")
  {
   if(!pos_risk_state.IsSymbolOpenShort(index)) return OpenShortPositionAt(index,1,comment);
   else if(DistanceLatestPriceToLastSellPrice(index)>grid_gap) return OpenShortPositionAt(index,pos_risk_state.LastShortLevelAt(index)+1,comment);
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CCOpenCloseLogic::TrendGridOpenLongAt(int index,double grid_gap=450.000000,string comment=" ")
  {
   if(!pos_risk_state.IsSymbolOpenLong(index))
     {
      double l=0.01*(pos_risk_state.LastShortLevelAt(index)+1);
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_BUY,l,latest_price[index].ask,0,0,comment);
      pos_risk_state.AddLongPositionIdAt(index,Trade.ResultOrder());
      pos_risk_state.AddLongPositionLevelAt(index,pos_risk_state.LastShortLevelAt(index)+1);
      return true;
     }
   else if(DistanceLatestPriceToLastBuyPrice(index)<-grid_gap)
     {
      double l=0.01*(pos_risk_state.LastShortLevelAt(index)+1);
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_BUY,l,latest_price[index].ask,0,0,comment);
      pos_risk_state.AddLongPositionIdAt(index,Trade.ResultOrder());
      pos_risk_state.AddLongPositionLevelAt(index,pos_risk_state.LastShortLevelAt(index)+1);
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CCOpenCloseLogic::TrendGridOpenShortAt(int index,double grid_gap=450.000000,string comment=" ")
  {
   if(!pos_risk_state.IsSymbolOpenShort(index))
     {
      double l=0.01*(pos_risk_state.LastLongLevelAt(index)+1);
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_SELL,l,latest_price[index].bid,0,0,"Open-Norm");
      pos_risk_state.AddShortPositionIdAt(index,Trade.ResultOrder());
      pos_risk_state.AddShortPositionLevelAt(index,pos_risk_state.LastLongLevelAt(index)+1);
      return true;
     }
   else if(DistanceLatestPriceToLastSellPrice(index)<-grid_gap)
     {
      double l=0.01*(pos_risk_state.LastLongLevelAt(index)+1);
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_SELL,l,latest_price[index].bid,0,0,"Open-Norm");
      pos_risk_state.AddShortPositionIdAt(index,Trade.ResultOrder());
      pos_risk_state.AddShortPositionLevelAt(index,pos_risk_state.LastLongLevelAt(index)+1);
      return true;
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CCOpenCloseLogic::OpenLongPositionAt(int index,int level,string comment=" ")
  {
   if(Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_BUY,0.01*level,latest_price[index].ask,0,0,comment))
     {
      pos_risk_state.AddLongPositionIdAt(index,Trade.ResultOrder());
      pos_risk_state.AddLongPositionLevelAt(index,level);
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CCOpenCloseLogic::OpenShortPositionAt(int index,int level,string comment=" ")
  {
   if(Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_SELL,level*0.01,latest_price[index].bid,0,0,comment))
     {
      pos_risk_state.AddShortPositionIdAt(index,Trade.ResultOrder());
      pos_risk_state.AddShortPositionLevelAt(index,level);
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
