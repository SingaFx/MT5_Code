//+------------------------------------------------------------------+
//|                                              GridRecoveryFBS.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include "GridBaseOperate.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridRecoveryFBS:public CStrategy
  {
protected:
   CGridBaseOperate  grid_operator;
   int               points_add;
   int               points_win;
   GridWinType       win_out_type;
   MqlRates          rates[];
public:
                     CGridRecoveryFBS(void){};
                    ~CGridRecoveryFBS(void){};
   void              Init(int add_points,int win_points,double l_base,GridLotsCalType l_type,GridWinType w_type,int max_pos);
   void              SetTypeFilling(const ENUM_ORDER_TYPE_FILLING filling=ORDER_FILLING_FOK) {grid_operator.SetTypeFilling(filling);};
protected:
   virtual void      OnEvent(const MarketEvent &event);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridRecoveryFBS::Init(int add_points,int win_points,double l_base,GridLotsCalType l_type,GridWinType w_type,int max_pos)
  {
   grid_operator.ExpertMagic(ExpertMagic());
   grid_operator.ExpertSymbol(ExpertSymbol());
   grid_operator.Init(l_base,l_type,max_pos);
   grid_operator.ReBuildPositionState();
   points_add=add_points;
   points_win=win_points;
   win_out_type=w_type;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridRecoveryFBS::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      grid_operator.RefreshPositionState();
      grid_operator.RefreshTickPrice();
      CopyRates(ExpertSymbol(),Timeframe(),1,1,rates);
      switch(win_out_type)
        {
         case ENUM_GRID_WIN_COST :
            if(grid_operator.pos_state.num_buy==0&&rates[0].close>rates[0].open&&grid_operator.pos_state.num_sell==0) grid_operator.BuildLongPositionWithCostTP(points_win);
            if(grid_operator.pos_state.num_sell==0&&grid_operator.pos_state.num_buy==0&&rates[0].close>rates[0].open) grid_operator.BuildShortPositionWithCostTP(points_win);
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
