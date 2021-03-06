//+------------------------------------------------------------------+
//|                                             CCOpenCloseLogic.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "ComplicatedControlBase.mqh"

class CCOpenCloseLogic:public CComplicatedControlBase
  {
protected:
//   不同的平仓逻辑--品种组合
   void              CheckAllPositionClose(double p_total, double p_per_lots);   // 检测所有仓位是否满足出场条件
//---不同平仓逻辑--单个品种进行判断   
   void              CheckOneSymbolPositionClose(int index_s,double p_total,double p_per_lots);
//---不同平仓逻辑--特殊处理  
   void              CheckWorstSymbolPartialPositionClose(double p_total,double p_per_lots);   // 检测最差品种对的分级出场是否满足条件
   void              CheckRiskSymbolsPartialPositionClose(double p_total,double p_per_lots);   // 检测多空不均衡组成的品种的分级出场是否满足条件
   void              CheckOpenAfterClose();   
   
   void              CheckSmallPositionTP(); // 将多空不均衡的小仓进行止盈(方便后续进行激励开仓操作)
   void              CheckOneSymbolCombinePositionClose();
   void              CheckPositionCloseForOpen();  
   
   void              PartialClosePosition(int index_c_long, int index_c_short, double profits_total_, double profits_per_lots_,string comment="");
   void              PartialClosePosition(int index,double profits_total_, double profits_per_lots_, ENUM_POSITION_TYPE p_type,string comment=""); // 对指定品种的指定方向进行分级出场
   void              PartialCloseLongPosition(int index_s, double profits_total_, double profits_per_lots_,string comment="");
   void              PartialCloseShortPosition(int index_s, double profits_total_, double profits_per_lots_,string comment="");
   void              CloseAllLongFirstShortPosition(int index_s, double profits_total_, double profits_per_lots_, string comment="");
   void              CloseAllShortFirstLongPosition(int index_s, double profits_total_, double profits_per_lots_, string comment="");
   void              CloseSmallLongPositionOpenNewLong(int i_s,int level);
   void              CloseSmallShortPositionOpenNewShort(int i_s,int level);
   
   
//   不同的开仓逻辑
   void              CheckNormGridPositionOpen();  // 正常网格的开仓操作
   void              CheckTrendGridPositionOpen(); // 趋势网格的开仓操作   
   
   bool              NormGridOpenLongAt(int index, double grid_gap=150,string comment=" "); // 对给定的索引进行正常的网格多头开仓操作
   bool              NormGridOpenShortAt(int index, double grid_gap=150,string comment=" ");  // 对给定的索引进行正常的网格空头开仓操作
   bool              TrendGridOpenLongAt(int index, double grid_gap=450, string comment=" "); // 对给定的索引进行q趋势的网格多头开仓操作
   bool              TrendGridOpenShortAt(int index, double grid_gap=450, string comment=" ");  // 对给定的索引进行趋势的网格空头开仓操作
   bool              OpenLongPositionAt(int index,int level,string comment=" ");
   bool              OpenShortPositionAt(int index,int level,string comment=" ");
   int               CalLeve(int level_hedge);
   int               CalLevel(double lots_hedge);
public:
                     CCOpenCloseLogic(void){};
                    ~CCOpenCloseLogic(void){};
  };
#include "LogicOpen.mqh"
#include "LogicClose.mqh"

void CCOpenCloseLogic::CheckOpenAfterClose(void)
   {
    for(int i=0;i<28;i++)
      {
       if(pos_risk_state.GetRiskTypeSTC(i)==ENUM_RISKSTC_DOUBLE_RISK)
         {
          if(pos_risk_state.GetSymbolDeltaRiskAt(i)>0.1)
            {
             //int new_level=CalLeve(pos_risk_state.LastLongLevelAt(i));
             int new_level=CalLevel(pos_risk_state.GetSymbolLongRiskAt(i));
             if(pos_risk_state.LastShortLevelAt(i)<new_level||DistanceLatestPriceToLastSellPrice(i)<-300)
               {
                CloseSmallShortPositionOpenNewShort(i,new_level);
               }
             
            }
          else if(pos_risk_state.GetSymbolDeltaRiskAt(i)<-0.1)
            {
             //int new_level=CalLeve(pos_risk_state.LastShortLevelAt(i));
             int new_level=CalLevel(pos_risk_state.GetSymbolShortRiskAt(i));
             if(pos_risk_state.LastLongLevelAt(i)<new_level||DistanceLatestPriceToLastBuyPrice(i)<-300)
               {
                CloseSmallLongPositionOpenNewLong(i,new_level);
               }
            }
         }
      }
   }
int CCOpenCloseLogic::CalLeve(int level_hedge)
   {
    if(level_hedge<10)
      {
       return 5;
      }
    if(level_hedge<20)
      {
       return 8; 
      }
    else return 10;
   }
int CCOpenCloseLogic::CalLevel(double lots_hedge)
   {
    return MathMax(int(lots_hedge/0.01/5),1);
   }