//+------------------------------------------------------------------+
//|                                    GridShockStrategyGradeOut.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property description "震荡网格--分级出场"
#property description "每次检测最后和最早的仓位组合是否满足止盈出场条件"

#include <strategy_czj\strategyGrid\GridFrame\GridShockBaseOperateGradeOut.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridShockStrategyGradeOut:public CGridShockBaseOperateGradeOut
  {
protected:
   double            tp_per_lots_buy;  // buy每手止盈
   double            tp_total_buy;  // buy总止盈
   double            tp_per_lots_sell;  // sell每手止盈
   double            tp_total_sell;  // sell总止盈
   int               max_level;
   int               ls_mode;
   ENUM_MARKET_EVENT_TYPE event_open_type;
public:
                     CGridShockStrategyGradeOut(void){SetGridParameter();};
                    ~CGridShockStrategyGradeOut(void){};
   void              SetGridParameter(int gap_grid,double per_lots_tp,double total_tp);
   virtual void      CheckPositionClose();
   virtual void      ShortPositionCloseCheck();
   virtual void      LongPositionCloseCheck();
   virtual void      CheckPositionOpen();
   void              CheckLongPositionOpen();
   void              CheckShortPositionOpen();
   void              SetBuyTP(double tp_total,double tp_per_lots);
   void              SetSellTP(double tp_total,double tp_per_lots);
   double            GetBuyTPPerLots(){return tp_per_lots_buy;};
   double            GetSellTPPerLots(){return tp_per_lots_sell;};
   double            GetBuyTPTotal(){return tp_total_buy;};
   double            GetSellTPTotal(){return tp_total_sell;};
   void              SetMaxLevel(int m_level=15);
   void              SetLSMode(int mode=0);
   void              SetEventOpen(ENUM_MARKET_EVENT_TYPE e_t=MARKET_EVENT_TICK);

protected:
   virtual void      OnEvent(const MarketEvent &event);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockStrategyGradeOut::SetGridParameter(int gap_grid=150,double per_lots_tp=100,double total_tp=20)
  {
   grid_gap_buy=gap_grid;
   grid_gap_sell=gap_grid;
   tp_per_lots_buy=per_lots_tp;
   tp_total_buy=total_tp;
   tp_per_lots_sell=per_lots_tp;
   tp_total_sell=total_tp;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockStrategyGradeOut::SetBuyTP(double tp_total,double tp_per_lots)
  {
   tp_total_buy=tp_total;
   tp_per_lots_buy=tp_per_lots;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockStrategyGradeOut::SetSellTP(double tp_total,double tp_per_lots)
  {
   tp_total_sell=tp_total;
   tp_per_lots_sell=tp_per_lots;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockStrategyGradeOut::SetMaxLevel(int m_level=15)
  {
   max_level=m_level;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockStrategyGradeOut::SetLSMode(int mode=0)
  {
   ls_mode=mode;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockStrategyGradeOut::SetEventOpen(ENUM_MARKET_EVENT_TYPE e_t=0)
  {
   event_open_type=e_t;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockStrategyGradeOut::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==event_open_type)
     {
      RefreshTickPrice();
      RefreshPositionState();
      RefreshCloseComment();
      CheckPositionClose();
      CheckPositionOpen();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockStrategyGradeOut::CheckPositionClose(void)
  {
// 仓位较重的方向，进行分级出场判断
//if(pos_state.lots_buy>=pos_state.lots_sell)
//  {
//   if(pos_state.num_buy==0) return;
//   LongPositionCloseCheck();
//   return;
//  }
//else
//  {
//   ShortPositionCloseCheck();
//   return;
//  }
   LongPositionCloseCheck();
   ShortPositionCloseCheck();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockStrategyGradeOut::LongPositionCloseCheck(void)
  {
   if(long_pos_id.Total()==0) return;
   int index=0;
   for(int i=long_pos_id.Total()-1;i>=0;i--)
     {
      PositionSelectByTicket(long_pos_id.At(i));
      if(PositionGetDouble(POSITION_PROFIT)<0)
        {
         index=i;
         break;
        }
     }
   if(index==0)
     {
      if(pos_state.GetProfitsLongPerLots()>tp_per_lots_buy || pos_state.profits_buy>tp_total_buy)
        {
         close_flag=pos_state.GetProfitsLongPerLots()>tp_per_lots_buy?"ALL CLOSE:TP_PER_LOTS":"ALL CLOSE:TP_TOTAL";
         CloseAllLongPosition();
        }
     }
   else if(index==long_pos_id.Total()-1)
     {
      return;
     }
   else
     {
      int l_pos[];
      ArrayResize(l_pos,long_pos_id.Total()-index);
      l_pos[0]=0;
      for(int i=1;i<long_pos_id.Total()-index;i++)
        {
         l_pos[i]=index+i;
        }
      if(GetPartialLongPositionProfitsPerLots(l_pos)>tp_per_lots_buy || GetPartialLongPositionProfits(l_pos)>tp_total_buy)
        {
         close_flag=GetPartialLongPositionProfitsPerLots(l_pos)>tp_per_lots_buy?"Partial CLOSE:TP_PER_LOTS":"Partial CLOSE:TP_TOTAL";
         ClosePartialLongPosition(l_pos);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockStrategyGradeOut::ShortPositionCloseCheck(void)
  {
   if(short_pos_id.Total()==0) return;
   int index=0;
   for(int i=short_pos_id.Total()-1;i>=0;i--)
     {
      PositionSelectByTicket(short_pos_id.At(i));
      if(PositionGetDouble(POSITION_PROFIT)<0)
        {
         index=i;
         break;
        }
     }
   if(index==0)
     {
      if(pos_state.GetProfitsShortPerLots()>tp_per_lots_sell || pos_state.profits_sell>tp_total_sell)
        {
         close_flag=pos_state.GetProfitsShortPerLots()>tp_per_lots_sell?"ALL CLOSE:TP_PER_LOTS":"ALL CLOSE:TP_TOTAL";
         CloseAllShortPosition();
        }
     }
   else if(index==short_pos_id.Total()-1)
     {
      return;
     }
   else
     {
      int s_pos[];
      ArrayResize(s_pos,short_pos_id.Total()-index);
      s_pos[0]=0;
      for(int i=1;i<short_pos_id.Total()-index;i++)
        {
         s_pos[i]=index+i;
        }
      if(GetPartialShortPositionProfitsPerLots(s_pos)>tp_per_lots_sell || GetPartialShortPositionProfits(s_pos)>tp_total_sell)
        {
         close_flag=GetPartialShortPositionProfitsPerLots(s_pos)>tp_per_lots_sell?"Partial CLOSE:TP_PER_LOTS":"Partial CLOSE:TP_TOTAL";
         ClosePartialShortPosition(s_pos);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockStrategyGradeOut::CheckPositionOpen(void)
  {
   if(ls_mode==0||ls_mode==1) CheckLongPositionOpen();
   if(ls_mode==0||ls_mode==2) CheckShortPositionOpen();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockStrategyGradeOut::CheckLongPositionOpen(void)
  {
   if(GetLastLongLevel()>max_level) return;
   if(pos_state.num_buy==0) BuildLongPosition();
   else if(DistanceAtLastLongPositionPrice()>grid_gap_buy) BuildLongPosition();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockStrategyGradeOut::CheckShortPositionOpen(void)
  {
   if(GetLastShortLevel()>max_level) return;
   if(pos_state.num_sell==0) BuildShortPosition();
   else if(DistanceAtLastShortPositionPrice()>grid_gap_sell) BuildShortPosition();
  }
//+------------------------------------------------------------------+
