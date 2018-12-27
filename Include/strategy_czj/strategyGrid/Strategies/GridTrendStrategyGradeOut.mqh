//+------------------------------------------------------------------+
//|                                    GridTrendStrategyGradeOut.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "GridTrendStrategy.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridTrendStrategyGradeOut:public CGridTrendStrategy
  {
   double            pair_pos_profits;
   double            pair_pos_lots;
   long              pos_id[2];

public:
                     CGridTrendStrategyGradeOut(void){};
                    ~CGridTrendStrategyGradeOut(void){};
protected:
   virtual void      CheckPositionClose();
   void              GetProfits();
   void              ClosePosition();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridTrendStrategyGradeOut::GetProfits(void)
  {

   pos_id[0]=long_pos_id.At(long_pos_id.Total()-1);
   pos_id[1]=short_pos_id.At(short_pos_id.Total()-1);

   pair_pos_profits=0;
   pair_pos_lots=0;
   for(int i=0;i<ArraySize(pos_id);i++)
     {
      PositionSelectByTicket(pos_id[i]);
      pair_pos_profits+=PositionGetDouble(POSITION_PROFIT);
      pair_pos_lots+=PositionGetDouble(POSITION_VOLUME);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridTrendStrategyGradeOut::ClosePosition(void)
  {
   for(int i=0;i<ArraySize(pos_id);i++)
     {
      Trade.PositionClose(pos_id[i],"close_current");
     }
   long_pos_level.Delete(long_pos_level.Total()-1);
   long_pos_id.Delete(long_pos_id.Total()-1);
   short_pos_level.Delete(short_pos_level.Total()-1);
   short_pos_id.Delete(short_pos_id.Total()-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridTrendStrategyGradeOut::CheckPositionClose(void)
  {
   if(pos_state.GetTotalNum()==0) return;
   Print(pos_state.GetLotsTotal(), ";;;; ", pos_state.GetProfitsTotal(),";;;",pos_state.GetTotalNum(),",",long_pos_id.Total(),",",short_pos_id.Total());
   if(pos_state.GetTotalNum()==1&&(pos_state.GetProfitsTotal()>tp_total||pos_state.GetProfitsPerLots()>tp_per_lots))
     {
      CloseAllLongPosition();
      CloseAllShortPosition();
      return;
     }
   GetProfits();
   //Print(pair_pos_profits, " ", pair_pos_lots);
   if(pair_pos_profits>tp_total || pair_pos_profits/pair_pos_lots>tp_per_lots)
     {
      ClosePosition();
     }
  }
//+------------------------------------------------------------------+
