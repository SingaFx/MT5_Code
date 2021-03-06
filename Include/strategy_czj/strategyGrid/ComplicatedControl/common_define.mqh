//+------------------------------------------------------------------+
//|                                                common_define.mqh |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Arrays\ArrayLong.mqh>
#include <Arrays\ArrayDouble.mqh>
#include <Arrays\ArrayInt.mqh>

// 平仓状态
enum ENUM_CLOSE_STATE
  {
   CLOSE_STATE_NORMAL_TP,  // 允许正常止盈平仓的操作
   CLOSE_STATE_DECREASE_RISK,  // 允许降风险进行的平仓操作
   CLOSE_STATE_FOBID // 不允许平仓操作
  };
// 开仓状态
enum ENUM_OPEN_STATE
  {
   OPEN_STATE_NORMAL_GRID, // 允许正常网格开仓和加仓操作
   OPEN_STATE_HEDGE, // 允许对冲风险的开仓和加仓操作
   OPEN_STATE_SIGNAL_GRID, // 允许网格加信号的加仓操作
   OPEN_STATE_FOBID, // 不允许开仓操作
   OPEN_STATE_EXCITATION,   // 开仓激励状态
   OPEN_STATE_RESTRAIN,  // 开仓抑制状态
   OPEN_STATE_NORMAL // 正常开仓状态
  };
// 8个货币
string CURRENCIES_8[]={"EUR","GBP","AUD","NZD","USD","CAD","CHF","JPY"};
// 28个品种
string SYMBOLS_28[]=
  {
   "EURGBP","EURAUD","EURNZD","EURUSD","EURCAD","EURCHF","EURJPY",
   "GBPAUD","GBPNZD","GBPUSD","GBPCAD","GBPCHF","GBPJPY",
   "AUDNZD","AUDUSD","AUDCAD","AUDCHF","AUDJPY",
   "NZDUSD","NZDCAD","NZDCHF","NZDJPY",
   "USDCAD","USDCHF","USDJPY",
   "CADCHF","CADJPY",
   "CHFJPY"
  };

// 风险状态定义
enum ENUM_RISK_STATE
  {
   RISK_STATE_NO_RISK,  // 无风险
   RISK_STATE_LITTLE_RISK // 中度风险
  };
//---风险信息
struct RiskInfor
  {
   double            lots_buy_c[8];  // 币种的多头手数
   double            lots_sell_c[8];   // 币种的空头手数
   double            lots_buy_s[28]; // 品种的多头手数
   double            lots_sell_s[28]; // 品种的空头手数
   void              RefreshRiskState();  // 刷新风险状态
   void              RefreshOpenAndCloseState(); // 刷新设置品种的开平仓状态
   
  };
void RiskInfor::RefreshRiskState(void)
   {
    
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RiskInfor::RefreshOpenAndCloseState(void)
  {
   int index;
   for(int i=0;i<8;i++)
     {
      for(int j=i;j<8;j++)
        {
         index=i*(15-i)/2+MathAbs(j-i)-1;
// 待算法根据风险设置开平仓状态
        }
     }
  }
//+------------------------------------------------------------------+
