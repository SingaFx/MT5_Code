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
   void              PartialClosePosition(int index, ENUM_POSITION_TYPE p_type,double profits_total_, double profits_per_lots_,string comment=""); // 对指定品种的指定方向进行分级出场
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
   void              ExcitationOpenOperate(int index, ENUM_POSITION_TYPE p_type);   // 对给定品种索引给定方向进行激励开仓的操作
   virtual void      ControlRisk(); // 控制风险操作

public:
                     CComplicatedControl(void);
                    ~CComplicatedControl(void){};
  };
#include "PositionCloseLogic.mqh"
#include "PositionOpenLogic.mqh"
#include "RiskCalculation.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CComplicatedControl::CComplicatedControl(void)
  {
   for(int i=0;i<28;i++)
     {
      open_long_state[i]=OPEN_STATE_NORMAL_GRID;
      open_short_state[i]=OPEN_STATE_NORMAL_GRID;
      close_long_state[i]=CLOSE_STATE_NORMAL_TP;
      close_short_state[i]=CLOSE_STATE_NORMAL_TP;
      handle_rsi[i]=iRSI(SYMBOLS_28[i],PERIOD_H1,12,PRICE_CLOSE);
      handle_ma_24[i]=iMA(SYMBOLS_28[i],PERIOD_H1,24,0,MODE_SMA,PRICE_CLOSE);
      handle_ma_200[i]=iMA(SYMBOLS_28[i],PERIOD_H1,200,0,MODE_SMA,PRICE_CLOSE);
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
void CComplicatedControl::ControlRisk(void)
  {
   for(int i=0;i<28;i++)
     {
      // 品种多头开仓逻辑控制：
      //不允许开仓的情况:两个货币中任意一个货币超过大阈值5；
      //正常网格开仓：其他
      //信号网格开仓：正向仓位>>反向仓位
      //对冲网格开仓:正向仓位<<反向仓位
      open_long_state[i]=OPEN_STATE_NORMAL_GRID;
      if(currencies_risk[c_index[i][0]][0]>20 || currencies_risk[c_index[i][1]][1]>20) // 品种对任意一个货币超过给定手数，该方向不能开仓
        {
         open_long_state[i]=OPEN_STATE_FOBID;
        }
      else if(sym_risk[i][0]>sym_risk[i][1]+2) // 品种多头风险
        {
         open_long_state[i]=OPEN_STATE_SIGNAL_GRID;
        }
      else if(sym_risk[i][1]>sym_risk[i][0]+2) // 品种空头风险
        {
         open_long_state[i]=OPEN_STATE_HEDGE;
        }
      //       品种空头开仓逻辑控制
      open_short_state[i]=OPEN_STATE_NORMAL_GRID;
      if(currencies_risk[c_index[i][0]][1]>20 || currencies_risk[c_index[i][1]][0]>20) // 品种对任意一个货币超过给定手数，该方向不能开仓
        {
         open_short_state[i]=OPEN_STATE_FOBID;
        }
      else if(sym_risk[i][0]>sym_risk[i][1]+2) // 品种多头风险
        {
         open_short_state[i]=OPEN_STATE_HEDGE;
        }
      else if(sym_risk[i][1]>sym_risk[i][0]+2) // 品种空头风险
        {
         open_short_state[i]=OPEN_STATE_SIGNAL_GRID;
        }
      // 品种平仓逻辑：
      //不能平仓：反向仓位大于正向仓位，且反向仓位对应的两个货币都达到一定阈值
      //正常止盈：其他
      //降风险平仓：正向仓位大于反向仓位，且正向仓位达到一定阈值
      //        品种多头平仓逻辑控制: 
      close_long_state[i]=CLOSE_STATE_NORMAL_TP;
      if(sym_risk[i][0]<sym_risk[i][1] && currencies_risk[c_index[i][0]][1]>8 && currencies_risk[c_index[i][1]][0]>8)
        {
         close_long_state[i]=CLOSE_STATE_FOBID;
        }
      else if(sym_risk[i][0]>sym_risk[i][1] && sym_risk[i][0]>5)
        {
         close_long_state[i]=CLOSE_STATE_DECREASE_RISK;
        }
      //        品种空头平仓逻辑控制
      close_short_state[i]=CLOSE_STATE_NORMAL_TP;
      if(sym_risk[i][0]>sym_risk[i][1] && currencies_risk[c_index[i][0]][0]>8 && currencies_risk[c_index[i][1]][1]>8)
        {
         close_short_state[i]=CLOSE_STATE_FOBID;
        }
      else if(sym_risk[i][0]<sym_risk[i][1] && sym_risk[i][1]>5)
        {
         close_short_state[i]=CLOSE_STATE_DECREASE_RISK;
        }
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
  }
void CComplicatedControl::CheckPositionOpen(const MarketEvent &event)
   {
    switch(event.period)
         {
          case PERIOD_M1 :
            for(int i=0;i<28;i++)
               {
                 RefreshOpenState();
                 PositionOpenByState(i);
               }
            break;
          case PERIOD_H1:
             PrintRiskInfor();
             break;
          default:
            break;
         }
    
   }
//+------------------------------------------------------------------+
