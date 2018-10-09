//+------------------------------------------------------------------+
//|                                                   GridSimple.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "GridBaseOperate.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridSimple:public CStrategy
  {
private:
   CGridBaseOperate  grid_operator;
   int               points_add;
   int               points_win;
   GridWinType       win_out_type;
public:
                     CGridSimple(void){};
                    ~CGridSimple(void){};
   void              Init(int add_points,int win_points,double l_base,GridLotsCalType l_type, GridWinType w_type);
protected:
   virtual void      OnEvent(const MarketEvent &event);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridSimple::Init(int add_points,int win_points,double l_base,GridLotsCalType l_type,GridWinType w_type)
  {
   grid_operator.ExpertMagic(ExpertMagic());
   grid_operator.ExpertSymbol(ExpertSymbol());
   grid_operator.Init(l_base,l_type);
   points_add=add_points;
   points_win=win_points;
   win_out_type=w_type;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridSimple::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      grid_operator.RefreshPositionState();
      switch(win_out_type)
        {
         case ENUM_GRID_WIN_COST :
            if(grid_operator.pos_state.num_buy==0) grid_operator.BuildLongPositionWithCostTP(points_win);
            if(grid_operator.pos_state.num_sell==0) grid_operator.BuildShortPositionWithCostTP(points_win);
            if(grid_operator.pos_state.num_buy>0 && grid_operator.DistanceAtLastBuyPrice()>points_add) grid_operator.BuildLongPositionWithCostTP(points_win);
            if(grid_operator.pos_state.num_sell>0 && grid_operator.DistanceAtLastSellPrice()>points_add) grid_operator.BuildShortPositionWithCostTP(points_win);
           break;
         case ENUM_GRID_WIN_LAST:
            if(grid_operator.pos_state.num_buy==0) grid_operator.BuildLongPositionWithTP(points_win);
            if(grid_operator.pos_state.num_sell==0) grid_operator.BuildShortPositionWithTP(points_win);
            if(grid_operator.pos_state.num_buy>0 && grid_operator.DistanceAtLastBuyPrice()>points_add) grid_operator.BuildLongPositionWithTP(points_win);
            if(grid_operator.pos_state.num_sell>0 && grid_operator.DistanceAtLastSellPrice()>points_add) grid_operator.BuildShortPositionWithTP(points_win);
            break;
         default:
           break;
        }
     }
  }
//+------------------------------------------------------------------+
