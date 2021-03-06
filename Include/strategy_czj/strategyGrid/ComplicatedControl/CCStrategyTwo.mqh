//+------------------------------------------------------------------+
//|                                                CCStrategyTwo.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "CCOpenCloseLogic.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct SymClose
  {
   double            close_price[];
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CCStrategyTwo:public CCOpenCloseLogic
  {
private:
   double            sym_points[28];
   SymClose          latest_close[28];
   double            last_close[28];
   double            delta_points[28];
   int               index_max_up;
   int               index_max_down;

protected:
   virtual void      CheckPositionClose(); // 平仓判断
   virtual void      CheckPositionOpen(const MarketEvent &event); // 开仓判断

   void              CheckPositonOpenChangeMax();  // 根据涨跌最大进行的开仓判断
   void              CheckPositionOpenHedgeRisk(); // 根据对冲风险进行的开仓判断
   
   void              CheckPositionCloseHedgeRisk();   // 以降低风险的部分平仓操作
   void              CheckPositionCloseByTP();  // 根据不同风险和收益进行的平仓

   void              RefreshMarketInfor(const MarketEvent &event);
   void              PositionOpenLongSymbolAt(int index,double l,string comment=" ");
   void              PositionOpenShortSymbolAt(int index,double l,string comment=" ");
   double            CalChangeMaxLots(double delta_max);
   double            CalHedgeHedegeLots(double delta_hedge);
public:
                     CCStrategyTwo(void);
                    ~CCStrategyTwo(void){};
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CCStrategyTwo::CCStrategyTwo(void)
  {
   double tmp_close[];
   for(int i=0;i<28;i++)
     {
      sym_points[i]=SymbolInfoDouble(SYMBOLS_28[i],SYMBOL_POINT);
      CopyClose(SYMBOLS_28[i],PERIOD_H1,0,2,tmp_close);
      last_close[i]=tmp_close[0];
     }
   AddBarOpenEvent(ExpertSymbol(),PERIOD_M5);
   AddBarOpenEvent(ExpertSymbol(),PERIOD_H1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCStrategyTwo::RefreshMarketInfor(const MarketEvent &event)
  {
   for(int i=0;i<28;i++)
     {
      delta_points[i]=(latest_price[i].ask-last_close[i])/sym_points[i];
      last_close[i]=latest_price[i].ask;
     }
   index_max_down=ArrayMinimum(delta_points);
   index_max_up=ArrayMaximum(delta_points);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCStrategyTwo::CheckPositionClose(void)
  {
   CheckAllPositionClose(50,20);
   RefreshRiskInfor();
   //CheckPositionCloseByTP();
   //CheckPositionCloseHedgeRisk();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCStrategyTwo::CheckPositionOpen(const MarketEvent &event)
  {
   switch(event.period)
     {
      case PERIOD_H1:
         RefreshRiskInfor();
         RefreshMarketInfor(event);
         CheckPositonOpenChangeMax();
         CheckPositionOpenHedgeRisk();
         //PrintRiskInfor();
         break;
         break;
      default:
         break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCStrategyTwo::CheckPositonOpenChangeMax(void)
  {
   if(delta_points[index_max_down]<-300) PositionOpenLongSymbolAt(index_max_down,CalChangeMaxLots(delta_points[index_max_down]),"M");
   if(delta_points[index_max_up]>300) PositionOpenShortSymbolAt(index_max_up,CalChangeMaxLots(delta_points[index_max_up]),"M");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCStrategyTwo::CheckPositionOpenHedgeRisk(void)
  {
   for(int i=0;i<28;i++)
     {
      if(delta_points[i]<-300 && pos_risk_state.IsSymbolShortRiskCalByCurrency(i)) PositionOpenLongSymbolAt(i,CalHedgeHedegeLots(delta_points[i]),"H");
      if(delta_points[i]>300&&pos_risk_state.IsSymbolLongRiskCalByCurrency(i)) PositionOpenShortSymbolAt(i,CalHedgeHedegeLots(delta_points[i]),"H");
     }
  }
void CCStrategyTwo::CheckPositionCloseHedgeRisk(void)
   {
    for(int i=0;i<28;i++)
      {
       if(pos_risk_state.GetRiskTypeSTC(i)==ENUM_RISKSTC_DOUBLE_RISK&&pos_risk_state.GetSymbolProfitsAt(i)>10)
         {
          if(pos_risk_state.GetSymbolDeltaRiskAt(i)>0) CloseLongPositionAt(i);
          else CloseShortPositionAt(i);
         }
      }
   }
void CCStrategyTwo::CheckPositionCloseByTP(void)
   {
    for(int i=0;i<28;i++)
      {
       for(int j=0;j<pos_risk_state.LongPosTotalAt(i);j++)
         {
          if(pos_risk_state.GetSymbolLongProfitsAt(i,j)/pos_risk_state.GetSymbolLongLotsAt(i,j)>500&&pos_risk_state.IsSymbolLongRiskCalByCurrency(i))
            {
             CloseLongPositionAt(i,j,">500 per lots");
             break;
            }
         }
       for(int j=0;j<pos_risk_state.ShortPosTotalAt(i);j++)
         {
          if(pos_risk_state.GetSymbolShortProfitsAt(i,j)/pos_risk_state.GetSymbolShortLotsAt(i,j)>500&&pos_risk_state.IsSymbolShortRiskCalByCurrency(i))
            {
             CloseShortPositionAt(i,j,">500 per lots");
            }
         }
      }
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCStrategyTwo::PositionOpenLongSymbolAt(int index,double l,string comment=" ")
  {
   if(l==0)
     {
      int level=pos_risk_state.LastLongLevelAt(index);
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_BUY,0.01*(level+1),latest_price[index].ask,0,0,comment);
      pos_risk_state.AddLongPositionIdAt(index,Trade.ResultOrder());
      pos_risk_state.AddLongPositionLevelAt(index,level+1);
     }
   else
     {
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_BUY,l,latest_price[index].ask,0,0,comment);
      pos_risk_state.AddLongPositionIdAt(index,Trade.ResultOrder());
      pos_risk_state.AddLongPositionLevelAt(index,1);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCStrategyTwo::PositionOpenShortSymbolAt(int index,double l,string comment=" ")
  {
   if(l==0)
     {
      int level=pos_risk_state.LastLongLevelAt(index);
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_SELL,0.01*(level+1),latest_price[index].bid,0,0,comment);
      pos_risk_state.AddShortPositionIdAt(index,Trade.ResultOrder());
      pos_risk_state.AddShortPositionLevelAt(index,level+1);
     }
   else
     {
      Trade.PositionOpen(SYMBOLS_28[index],ORDER_TYPE_SELL,l,latest_price[index].bid,0,0,comment);
      pos_risk_state.AddShortPositionIdAt(index,Trade.ResultOrder());
      pos_risk_state.AddShortPositionLevelAt(index,1);
     }
  }
double CCStrategyTwo::CalChangeMaxLots(double delta_max)
   {
    if(MathAbs(delta_max)>500) return 0.1;
    if(MathAbs(delta_max)>400) return 0.09;
    return 0.08;
   }
double CCStrategyTwo::CalHedgeHedegeLots(double delta_hedge)
   {
    if(MathAbs(delta_hedge)>500) return 0.05;
    if(MathAbs(delta_hedge)>400) return 0.04;
    return 0.03;
   }
//+------------------------------------------------------------------+
