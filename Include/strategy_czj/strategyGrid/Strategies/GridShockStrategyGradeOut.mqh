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
   int               grid_gap;  // 网格间距
   double            tp_per_lots;  // 每手止盈
   double            tp_total;  // 总止盈
public:
                     CGridShockStrategyGradeOut(void){SetGridParameter();};
                    ~CGridShockStrategyGradeOut(void){};
   void              SetGridParameter(int gap_grid,double per_lots_tp,double total_tp);
protected:
   virtual void      OnEvent(const MarketEvent &event);
   virtual void      CheckPositionClose();
   virtual void      CheckPositionOpen();
   void              ShortPositionCloseCheck();
   void              LongPositionCloseCheck();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockStrategyGradeOut::SetGridParameter(int gap_grid=150,double per_lots_tp=100,double total_tp=20)
  {
   grid_gap=gap_grid;
   tp_per_lots=per_lots_tp;
   tp_total=total_tp;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockStrategyGradeOut::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
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
   if(pos_state.lots_buy>=pos_state.lots_sell)
     {
      if(pos_state.num_buy==0) return;
      LongPositionCloseCheck();
      return;
     }
   else
     {
      ShortPositionCloseCheck();
      return;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockStrategyGradeOut::LongPositionCloseCheck(void)
  {
   if(pos_state.num_buy<3)
     {
      if(pos_state.GetProfitsLongPerLots()>tp_per_lots || pos_state.profits_buy>tp_total)
         {
          close_flag=pos_state.GetProfitsLongPerLots()>tp_per_lots?"ALL CLOSE:TP_PER_LOTS":"ALL CLOSE:TP_TOTAL";
          CloseAllLongPosition();
         }
     }
   else
     {
      int l_pos[3];
      l_pos[0]=0;
      l_pos[1]=pos_state.num_buy-2;
      l_pos[2]=pos_state.num_buy-1;
      if(GetPartialLongPositionProfitsPerLots(l_pos)>tp_per_lots || GetPartialLongPositionProfits(l_pos)>tp_total) 
         {
          close_flag=GetPartialLongPositionProfitsPerLots(l_pos)>tp_per_lots?"Partial CLOSE:TP_PER_LOTS":"Partial CLOSE:TP_TOTAL";
          ClosePartialLongPosition(l_pos);
         }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockStrategyGradeOut::ShortPositionCloseCheck(void)
  {
   if(pos_state.num_sell<3)
     {
      if(pos_state.GetProfitsShortPerLots()>tp_per_lots || pos_state.profits_sell>tp_total) 
         {
          close_flag=pos_state.GetProfitsShortPerLots()>tp_per_lots?"ALL CLOSE:TP_PER_LOTS":"ALL CLOSE:TP_TOTAL";
          CloseAllShortPosition();
         }
     }
   else
     {
      int s_pos[3];
      s_pos[0]=0;
      s_pos[1]=pos_state.num_sell-2;
      s_pos[2]=pos_state.num_sell-1;
      if(GetPartialShortPositionProfitsPerLots(s_pos)>tp_per_lots || GetPartialShortPositionProfits(s_pos)>tp_total) 
         {
          close_flag=GetPartialShortPositionProfitsPerLots(s_pos)>tp_per_lots?"Partial CLOSE:TP_PER_LOTS":"Partial CLOSE:TP_TOTAL";
          ClosePartialShortPosition(s_pos);
         }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockStrategyGradeOut::CheckPositionOpen(void)
  {
   if(pos_state.num_buy==0) BuildLongPosition();
   else if(DistanceAtLastLongPositionPrice()>grid_gap) BuildLongPosition();
   if(pos_state.num_sell==0) BuildShortPosition();
   else if(DistanceAtLastShortPositionPrice()>grid_gap) BuildShortPosition();
  }
//+------------------------------------------------------------------+
