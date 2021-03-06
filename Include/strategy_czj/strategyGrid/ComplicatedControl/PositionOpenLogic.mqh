//+------------------------------------------------------------------+
//|                                            PositionOpenLogic.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property description "开仓逻辑"
#property description "    --开仓或者加仓的时如果是降低仓位风险的操作应该激励该行为"
#property description "          1.手数应该大于等于正常的加仓手数，结合仓位风险计算新的手数"
#property description "          2.网格大小应该小于正常的网格大小"
#property description "    --开仓或者加仓的时如果是提高仓位风险的操作应该怎么做？"
#include "ComplicatedControlStrategy.mqh"

void CComplicatedControl::PositionOpenByState(int index)
   {
    //switch(open_long_state[index])
    //  {
    //   case OPEN_STATE_NORMAL:
    //     NormGridOpenLongOnBarM1(index);
    //     break;
    //   case OPEN_STATE_EXCITATION:
    //     ExcitationOpenLongOperate(index);
    //      break;
    //   case OPEN_STATE_RESTRAIN:
    //      RestrainOpenLongOperate(index);
    //      break;
    //   default:
    //     break;
    //  }
    // switch(open_short_state[index])
    //  {
    //   case OPEN_STATE_NORMAL :
    //     NormGridOpenShortOnBarM1(index);
    //     break;
    //   case OPEN_STATE_EXCITATION:
    //     ExcitationOpenShortOperate(index);
    //      break;
    //   case OPEN_STATE_RESTRAIN:
    //      RestrainOpenShortOperate(index);
    //      break;
    //   default:
    //     break;
    //  }   
   }
void CComplicatedControl::ExcitationOpenLongOperate(int index)
   {
   if(long_pos_id[index].Total()==0)
     {
      //double l=(short_pos_level[index].At(short_pos_level[index].Total()-1))*0.01;
      double l=0.1;
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_BUY,l,latest_price[index].ask,0,0,"Excitation");
      long_pos_id[index].Add(Trade.ResultOrder());
      //long_pos_level[index].Add(short_pos_level[index].At(short_pos_level[index].Total()-1));
      long_pos_level[index].Add(10);
     }
   else if(DistanceLatestPriceToLastBuyPrice(index)>200)
     {
      double l=(long_pos_level[index].At(long_pos_level[index].Total()-1)+1)*0.1;
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_BUY,l,latest_price[index].ask,0,0,"Excitation");
      long_pos_id[index].Add(Trade.ResultOrder());
      long_pos_level[index].Add(long_pos_level[index].At(long_pos_level[index].Total()-1)+1);
     }      
   }
void CComplicatedControl::ExcitationOpenShortOperate(int index)
   {
   if(short_pos_id[index].Total()==0)
     {
      //double l=(long_pos_level[index].At(long_pos_level[index].Total()-1))*0.01;
      double l=0.1;
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_SELL,l,latest_price[index].bid,0,0,"Excitation");
      short_pos_id[index].Add(Trade.ResultOrder());
      //short_pos_level[index].Add(long_pos_level[index].At(long_pos_level[index].Total()-1));
      short_pos_level[index].Add(10);
     }
   else if(DistanceLatestPriceToLastSellPrice(index)>200)
     {
      double l=(short_pos_level[index].At(short_pos_level[index].Total()-1)+1)*0.1;
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_SELL,l,latest_price[index].bid,0,0,"Excitation");
      short_pos_id[index].Add(Trade.ResultOrder());
      short_pos_level[index].Add(short_pos_level[index].At(short_pos_level[index].Total()-1)+1);
     }      
   }
void CComplicatedControl::RestrainOpenLongOperate(int index)
   {
    if(long_pos_id[index].Total()==0) return;
   else if(DistanceLatestPriceToLastBuyPrice(index)>500)
     {
      double l=(long_pos_level[index].At(long_pos_level[index].Total()-1)+1)*0.01*2;
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_BUY,l,latest_price[index].ask,0,0,"Restrain");
      long_pos_id[index].Add(Trade.ResultOrder());
      long_pos_level[index].Add(long_pos_level[index].At(long_pos_level[index].Total()-1)+1);
     }     
   }
void CComplicatedControl::RestrainOpenShortOperate(int index)
   {
    if(short_pos_id[index].Total()==0) return;
   else if(DistanceLatestPriceToLastSellPrice(index)>500)
     {
      double l=(short_pos_level[index].At(short_pos_level[index].Total()-1)+1)*0.01*2;
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_SELL,l,latest_price[index].bid,0,0,"Restrain");
      short_pos_id[index].Add(Trade.ResultOrder());
      short_pos_level[index].Add(short_pos_level[index].At(short_pos_level[index].Total()-1)+1);
     }   
   }
//+------------------------------------------------------------------+
//|              正常网格多头的开仓和加仓操作OnM1                    |
//+------------------------------------------------------------------+
void CComplicatedControl::NormGridOpenLongOnBarM1(int index)
  {
   if(long_pos_id[index].Total()==0)
     {
      double l=0.01;
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_BUY,l,latest_price[index].ask,0,0);
      long_pos_id[index].Add(Trade.ResultOrder());
      long_pos_level[index].Add(1);
     }
   else if(DistanceLatestPriceToLastBuyPrice(index)>300)
     {
      double l=(long_pos_level[index].At(long_pos_level[index].Total()-1)+1)*0.01;
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_BUY,l,latest_price[index].ask,0,0);
      long_pos_id[index].Add(Trade.ResultOrder());
      long_pos_level[index].Add(long_pos_level[index].At(long_pos_level[index].Total()-1)+1);
     }
  }
//+------------------------------------------------------------------+
//|             对冲网格多头的开仓和加仓操作OnM1                    |
//+------------------------------------------------------------------+
void CComplicatedControl::HedgeGridOpenLongOnBarM1(int index)
  {
   if(long_pos_id[index].Total()==0)
     {
      double l=0.01;
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_BUY,l,latest_price[index].ask,0,0);
      long_pos_id[index].Add(Trade.ResultOrder());
      long_pos_level[index].Add(1);
     }
   else if(DistanceLatestPriceToLastBuyPrice(index)>100)
     {
      double l=(long_pos_level[index].At(long_pos_level[index].Total()-1)+1)*0.01;
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_BUY,l,latest_price[index].ask,0,0);
      long_pos_id[index].Add(Trade.ResultOrder());
      long_pos_level[index].Add(long_pos_level[index].At(long_pos_level[index].Total()-1)+1);
     }
  }
//+------------------------------------------------------------------+
//|               信号网格多头的加仓操作OnH1                             |
//+------------------------------------------------------------------+
void CComplicatedControl::SignalGridOpenLongOnBarH1(int index)
  {
   if(value_rsi[index].ind_value[2]<20)
     {
      double l=(long_pos_level[index].At(long_pos_level[index].Total()-1)+1)*0.01;
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_BUY,l,latest_price[index].ask,0,0);
      long_pos_id[index].Add(Trade.ResultOrder());
      long_pos_level[index].Add(long_pos_level[index].At(long_pos_level[index].Total()-1)+1);
     }
  }
//+------------------------------------------------------------------+
//|                对冲网格多头的加仓操作OnH1                        |
//+------------------------------------------------------------------+
void CComplicatedControl::HedgeGridOpenLongOnBarH1(int index)
  {
   if(latest_price[index].ask<value_ma_24[index].ind_value[1])
     {
      double l=(long_pos_level[index].At(long_pos_level[index].Total()-1))*0.01;
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_BUY,l,latest_price[index].ask,0,0);
      long_pos_id[index].Add(Trade.ResultOrder());
      long_pos_level[index].Add(long_pos_level[index].At(long_pos_level[index].Total()-1));
     }
  }
//+------------------------------------------------------------------+
//|              正常网格short的开仓和加仓操作OnM1                    |
//+------------------------------------------------------------------+
void CComplicatedControl::NormGridOpenShortOnBarM1(int index)
  {
   if(short_pos_id[index].Total()==0)
     {
      double l=0.01;
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_SELL,l,latest_price[index].bid,0,0);
      short_pos_id[index].Add(Trade.ResultOrder());
      short_pos_level[index].Add(1);
     }
   else if(DistanceLatestPriceToLastSellPrice(index)>300)
     {
      double l=(short_pos_level[index].At(short_pos_level[index].Total()-1)+1)*0.01;
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_SELL,l,latest_price[index].bid,0,0);
      short_pos_id[index].Add(Trade.ResultOrder());
      short_pos_level[index].Add(short_pos_level[index].At(short_pos_level[index].Total()-1)+1);
     }
  }
//+------------------------------------------------------------------+
//|             对冲网格short的开仓和加仓操作OnM1                    |
//+------------------------------------------------------------------+
void CComplicatedControl::HedgeGridOpenShortOnBarM1(int index)
  {
   if(short_pos_id[index].Total()==0)
     {
      double l=0.01;
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_SELL,l,latest_price[index].bid,0,0);
      short_pos_id[index].Add(Trade.ResultOrder());
      short_pos_level[index].Add(1);
     }
   else if(DistanceLatestPriceToLastSellPrice(index)>100)
     {
      double l=(short_pos_level[index].At(short_pos_level[index].Total()-1)+1)*0.01;
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_SELL,l,latest_price[index].bid,0,0);
      short_pos_id[index].Add(Trade.ResultOrder());
      short_pos_level[index].Add(short_pos_level[index].At(short_pos_level[index].Total()-1)+1);
     }
  }
//+------------------------------------------------------------------+
//|               信号网格short的加仓操作OnH1                             |
//+------------------------------------------------------------------+
void CComplicatedControl::SignalGridOpenShortOnBarH1(int index)
  {
   if(value_rsi[index].ind_value[2]>80)
     {
      double l=(long_pos_level[index].At(long_pos_level[index].Total()-1)+1)*0.01;
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_SELL,l,latest_price[index].bid,0,0);
      short_pos_id[index].Add(Trade.ResultOrder());
      short_pos_level[index].Add(short_pos_level[index].At(short_pos_level[index].Total()-1)+1);
     }
  }
//+------------------------------------------------------------------+
//|                对冲网格short的加仓操作OnH1                       |
//+------------------------------------------------------------------+
void CComplicatedControl::HedgeGridOpenShortOnBarH1(int index)
  {
   if(latest_price[index].bid>value_ma_24[index].ind_value[1])
     {
      double l=0.01;
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_SELL,l,latest_price[index].bid,0,0);
      short_pos_id[index].Add(Trade.ResultOrder());
      short_pos_level[index].Add(1);
     }
  }