//+------------------------------------------------------------------+
//|                                   ComplicatedControlStrategy.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include "ComplicatedControlBase.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct IndValueTotal3
  {
   double            ind_value[3];
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CComplicatedControl:public CComplicatedControlBase
  {
private:
   int               handle_rsi[28];
   int               handle_ma_24[28];
   int               handle_ma_200[28];

   IndValueTotal3    value_rsi[28];
   IndValueTotal3    value_ma_24[28];
   IndValueTotal3    value_ma_200[28];
protected:
   virtual void      CopyBufferOnBarH1(); // 复制H1上指标值的操作
   virtual void      CheckPositionClose(); // 平仓判断
   virtual void      CheckPositionOpen(const MarketEvent &event); // 开仓判断
//  计算风险相关的参数
   virtual void  RefreshRiskInfor();  
   void          RefreshOpenState();   // 基于当前的仓位，计算开仓状态 
//   不同的平仓逻辑
   void              CheckAllPositionClose();   // 检测所有仓位是否满足出场条件
   void              CheckOneSymbolPositionClose();   // 检测单一品种是否满足出场条件
   void              CheckOneSymbolPartialPositionClose();  // 检测单一品种的部分仓位是否满足出场条件
   void              CheckWorstSymbolPartialPositionClose();   // 检测最差品种对的分级出场是否满足条件
   void              CheckRiskSymbolsPartialPositionClose();   // 检测多空不均衡组成的品种的分级出场是否满足条件
   void              CheckSmallPositionTP(); // 将多空不均衡的小仓进行止盈(方便后续进行激励开仓操作)
   void              CheckOneSymbolCombinePositionClose();
   void              PartialClosePosition(int index_c_long, int index_c_short, double profits_total_, double profits_per_lots_,string comment="");
   void              PartialClosePosition(int index,double profits_total_, double profits_per_lots_, ENUM_POSITION_TYPE p_type,string comment=""); // 对指定品种的指定方向进行分级出场
   void              PartialCloseLongPosition(int index_s, double profits_total_, double profits_per_lots_,string comment="");
   void              PartialCloseShortPosition(int index_s, double profits_total_, double profits_per_lots_,string comment="");
   void              CloseAllLongFirstShortPosition(int index_s, double profits_total_, double profits_per_lots_, string comment="");
   void              CloseAllShortFirstLongPosition(int index_s, double profits_total_, double profits_per_lots_, string comment="");
   
//    不同的开仓逻辑--Old
   virtual void      NormGridOpenLongOnBarM1(int index);   // M1--正常网格开仓和加仓操作
   virtual void      HedgeGridOpenLongOnBarM1(int index);  // M1--对冲开仓和加仓操作（空仓和满足回调点位时）
   virtual void      SignalGridOpenLongOnBarH1(int index); // H1--信号网格加仓操作
   virtual void      HedgeGridOpenLongOnBarH1(int index);  // H1--对冲开仓和加仓操作                                                        //
   virtual void      NormGridOpenShortOnBarM1(int index);   // M1--正常网格开仓和加仓操作
   virtual void      HedgeGridOpenShortOnBarM1(int index);  // M1--对冲开仓和加仓操作
   virtual void      SignalGridOpenShortOnBarH1(int index); // H1--信号网格加仓操作
   virtual void      HedgeGridOpenShortOnBarH1(int index);  // H1--对冲开仓和加仓操作
//    不同的开仓逻辑-new
   void              PositionOpenByState(int index); // 根据开仓状态进行开仓操作
   void              ExcitationOpenLongOperate(int index);   // 对给定品种索引多头方向进行激励开仓的操作
   void              ExcitationOpenShortOperate(int index);  // 对给定品种索引空头方向进行激励开仓的操作
   void              RestrainOpenLongOperate(int index);   // 对给定品种索引多头方向进行抑制开仓的操作
   void              RestrainOpenShortOperate(int index);  // 对给定品种索引空头方向进行抑制开仓的操作
//   不同的开仓逻辑-new2
   void              CheckNormGridPositionOpen();  // 正常网格的开仓操作
   bool              NormGridOpenLongAt(int index, double grid_gap=150); // 对给定的索引进行正常的网格多头开仓操作
   bool              NormGridOpenShortAt(int index, double grid_gap=150);  // 对给定的索引进行正常的网格空头开仓操作
   void              CheckHedgeGridPositionOpen(); // 对冲网格操作
   bool              HedgeGridOpenLongAt(int index); // 对给定的索引进行对冲的网格多头开仓操作
   bool              HedgeGridOpenShortAt(int index);  // 对给定的索引进行对冲的网格空头开仓操作 
   void              CheckSignalGridPositionOpen();   //对给定索引进行信号网格的开仓
   void              SignalGridOpenLongAt(int index); // 对给定的索引进行对冲的网格多头开仓操作
   void              SignalGridOpenShortAt(int index);  // 对给定的索引进行对冲的网格空头开仓  
   void              CheckBestSymbolOpen();  // 寻找最佳的品种和方向进行加仓
   void              CheckRebuildSymbolOpen();  // 将对冲方向仓位小且盈利 平仓后重新挂较大的仓
   void              RebuildSymbolPosition(int index);   // 重新将小仓位止盈后开仓
   bool              OpenHedgeSymbol(int c_long, int c_short); // 根据需要做多和做空币种的索引进行开仓操作
   bool              OpenNormalSymbol(int c_long, int c_short);   // 正常网格开仓
   void              OpenFirstLongPositionSymbolAt(int index, int level);  // 指定品种开多头的第一个仓位，使用指定等级
   void              OpenFirstShortPositionSymbolAt(int index, int level);  // 指定品种开多头的第一个仓位，使用指定等级

public:
                     CComplicatedControl(void);
                    ~CComplicatedControl(void){};
  };
#include "PositionCloseLogic.mqh"
#include "PositionOpenLogic.mqh"
#include "PositionOpenLogic2.mqh"
#include "RiskCalculation.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CComplicatedControl::CComplicatedControl(void)
  {
   for(int i=0;i<28;i++)
     {
      //open_long_state[i]=OPEN_STATE_NORMAL_GRID;
      //open_short_state[i]=OPEN_STATE_NORMAL_GRID;
      //close_long_state[i]=CLOSE_STATE_NORMAL_TP;
      //close_short_state[i]=CLOSE_STATE_NORMAL_TP;
      //handle_rsi[i]=iRSI(SYMBOLS_28[i],PERIOD_H1,12,PRICE_CLOSE);
      //handle_ma_24[i]=iMA(SYMBOLS_28[i],PERIOD_H1,24,0,MODE_SMA,PRICE_CLOSE);
      //handle_ma_200[i]=iMA(SYMBOLS_28[i],PERIOD_H1,200,0,MODE_SMA,PRICE_CLOSE);
     }
   AddBarOpenEvent(ExpertSymbol(),PERIOD_M1);
   AddBarOpenEvent(ExpertSymbol(),PERIOD_H1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicatedControl::CopyBufferOnBarH1(void)
  {
   for(int i=0;i<28;i++)
     {
      CopyBuffer(handle_rsi[i],0,0,3,value_rsi[i].ind_value);
      CopyBuffer(handle_ma_200[i],0,0,3,value_ma_200[i].ind_value);
      CopyBuffer(handle_ma_24[i],0,0,3,value_ma_24[i].ind_value);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CComplicatedControl::CheckPositionClose(void)
  {
   CheckAllPositionClose();
   RefreshRiskInfor();
   CheckOneSymbolPositionClose();
   RefreshRiskInfor();
   CheckWorstSymbolPartialPositionClose();
   RefreshRiskInfor();
   CheckRiskSymbolsPartialPositionClose();
   RefreshRiskInfor();
   //CheckSmallPositionTP();
  }
void CComplicatedControl::CheckPositionOpen(const MarketEvent &event)
   {
    switch(event.period)
         {
          case PERIOD_M1 :
            for(int i=0;i<28;i++)
               {
                 //RefreshOpenState();
                 //PositionOpenByState(i);
                 //CheckHedgeGridPositionOpen();
                 RefreshRiskInfor();
                 CheckNormGridPositionOpen();
                 //CheckBestSymbolOpen();
               }
            break;
          case PERIOD_H1:
              RefreshRiskInfor();
              //CheckSignalGridPositionOpen();
             PrintRiskInfor();
             break;
          default:
            break;
         }
    
   }
//+------------------------------------------------------------------+
