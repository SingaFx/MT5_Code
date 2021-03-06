//+------------------------------------------------------------------+
//|                                        GridLinearCombination.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "GridBaseOperateLinearCombination.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridLinearCombination:public CStrategy
  {
private:
   MqlDateTime       dt;
   double            points_add;
   double            points_tp;
protected:
   CGridBaseOperateLinearCombination grid_lc;
public:
                     CGridLinearCombination(void){};
                    ~CGridLinearCombination(void){};
   void SetLinearCombinationParameter(const string &sym[],const double &al[]){grid_lc.Init(sym,al);};
   void SetGridParameters(int add_p,int tp_p,int pos_max, double b_lots);
protected:
   virtual void      OnEvent(const MarketEvent &event);
   void              CheckPositionClose();
   void              CheckPositionOpen();
  };
void CGridLinearCombination::SetGridParameters(int add_p,int tp_p,int pos_max, double b_lots)
   {
    points_add=add_p;
    points_tp=tp_p;
    grid_lc.SetPosMax(pos_max);
    grid_lc.SetBaseLots(b_lots);
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridLinearCombination::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      grid_lc.RefreshPositionState();
      grid_lc.RefreshTickPrice();
      TimeToStruct(TimeCurrent(),dt);
      if(dt.hour*60+dt.min>23*60+50 || dt.hour*0+dt.min<10) // 前后日切换时候的20分钟不进行开仓交易
        {
         return;
        }
      CheckPositionClose();
      grid_lc.RefreshPositionState();
      CheckPositionOpen();
     }
  }
void CGridLinearCombination::CheckPositionClose(void)
   {
    if(grid_lc.pos_state.num_buy>0 && grid_lc.DistanceAtLastBuyPrice()<-points_tp)
      {
       grid_lc.CloseLongPosition();
      }
    if(grid_lc.pos_state.num_sell>0 && grid_lc.DistanceAtLastSellPrice()<-points_tp) 
      {
       grid_lc.CloseShortPosition();
      }
    //if(grid_lc.pos_state.num_buy>0 && grid_lc.pos_state.profits_buy/grid_lc.pos_state.num_buy>5)
    //  {
    //   grid_lc.CloseLongPosition();
    //  }
    //if(grid_lc.pos_state.num_sell>0 && grid_lc.pos_state.profits_sell/grid_lc.pos_state.num_sell>5) 
    //  {
    //   grid_lc.CloseShortPosition();
    //  }
   }
void CGridLinearCombination::CheckPositionOpen(void)
   {
     if(grid_lc.pos_state.num_buy==0)
        {
         grid_lc.BuildLongPosition();
        }
      else if(grid_lc.DistanceAtLastBuyPrice()>points_add)
        {
         grid_lc.BuildLongPosition();
        }
      if(grid_lc.pos_state.num_sell==0)
        {
         grid_lc.BuildShortPosition();
        }
      else if(grid_lc.DistanceAtLastSellPrice()>points_add)
        {
         grid_lc.BuildShortPosition();
        }
   }
//+------------------------------------------------------------------+
