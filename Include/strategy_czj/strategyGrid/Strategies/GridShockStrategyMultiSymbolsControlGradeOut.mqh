//+------------------------------------------------------------------+
//|                 GridShockStrategyMultiSymbolsControlGradeOut.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property description "震荡网格--分级出场(多品种风险控制)"
#property description "分级出场:每次检测最后和最早的仓位组合是否满足止盈出场条件"
#property description "多品种风险控制:根据风险情况，改变网格距离，改变TP"

#include <strategy_czj\strategyGrid\Strategies\GridShockStrategyGradeOut.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridShockStrategyMultiSymbolsControlGradeOut:public CStrategy
  {
protected:
   string            syms[]; // 品种
   CGridShockStrategyGradeOut grid_operator[]; // 分级出场网格策略数组
protected:
   void              RefreshStrategyState(); // 刷新策略信息
   void              CheckPositionClose();   // 检测平仓
   void              CheckPositionOpen(); // 检测开仓
   void              RiskControl(); // 风险控制操作
   void              ChangeGridGap();  // 改变网格大小
   void              ChangeGridTP();   // 改变网格止盈值   
   virtual void      OnEvent(const MarketEvent &event);
public:
                     CGridShockStrategyMultiSymbolsControlGradeOut(void);
                    ~CGridShockStrategyMultiSymbolsControlGradeOut(void);
   void              SetSymbols(const string &syms_[]){ArrayCopy(syms,syms_);};
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridShockStrategyMultiSymbolsControlGradeOut::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      CheckPositionClose();
      RefreshStrategyState();
      RiskControl();
      CheckPositionOpen();
     }
  }
//+------------------------------------------------------------------+
