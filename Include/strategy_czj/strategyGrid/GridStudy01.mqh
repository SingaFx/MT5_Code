//+------------------------------------------------------------------+
//|                                                  GridStudy01.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include "GridSingleSymbol.mqh"
#include <Math\Alglib\matrix.mqh>

string CURRENCIES[]={"EUR","GBP","AUD","NZD","USD","CAD","CHF","JPY"};
string SYMBOLS_28[]=
  {
   "EURGBP","EURAUD","EURNZD","EURUSD","EURCAD","EURCHF","EURJPY",
   "GBPAUD","GBPNZD","GBPUSD","GBPCAD","GBPCHF","GBPJPY",
   "AUDNZD","AUDUSD","AUDCAD","AUDCHF","AUDJPY",
   "NZDUSD","NZDCAD","NZDCHF","NZDJPY",
   "USDCAD","CADCHF","CADJPY",
   "USDCHF","CHFJPY",
   "USDJPY"
  };
//+------------------------------------------------------------------+
//|     多个品种对的各自加仓策略                                     |
//+------------------------------------------------------------------+
class CGridStudy01:public CStrategy
  {
private:
   int               num_symbols;
   int               symbol_index[];
   CGridSingleSymbol child_strategy[28];
   double            base_lots;
   CMatrixDouble     symbol_lots; // 上三角存储多单手数，下三角存储空单手数
   double            currency_risk[8];
   int               index_long;
   int               index_short;

protected:
   void              RefreshTickData();
   void              RefreshPositionState();
   void              CheckPositionClose();
   void              CheckPositionOpen();
   void              CheckPositionOpenUnderRiskControl();
   void              OpenNewPositionByRiskControl1();
   void              OpenNewPositionByRiskControl2();
   double            CalExpLots(int index);
   bool              IsEmptyPosition();
public:
                     CGridStudy01(void);
                    ~CGridStudy01(void){};
   virtual void      OnEvent(const MarketEvent &event);
  };
//+------------------------------------------------------------------+
//|               初始化                                             |
//+------------------------------------------------------------------+
CGridStudy01::CGridStudy01(void)
  {

//int symbol_index_for_strategy[]={0,3,9};
   int symbol_index_for_strategy[]={0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27};
   ArrayCopy(symbol_index,symbol_index_for_strategy);
   num_symbols=ArraySize(symbol_index);
   for(int i=0;i<num_symbols;i++)
     {
      child_strategy[symbol_index[i]].ExpertSymbol(SYMBOLS_28[symbol_index[i]]);
      SymbolSelect(SYMBOLS_28[symbol_index[i]],true);
      child_strategy[symbol_index[i]].ExpertMagic(ExpertMagic()+symbol_index[i]);
     }
   base_lots=0.01;
   symbol_lots.Resize(8,8);
  }
//+------------------------------------------------------------------+
//|               事件处理                                           |
//+------------------------------------------------------------------+
void CGridStudy01::OnEvent(const MarketEvent &event)
  {
// 监控品种tick事件发生时的处理
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      RefreshTickData();
      RefreshPositionState();
      CheckPositionClose();
      RefreshPositionState();
      //CheckPositionOpen();
      CheckPositionOpenUnderRiskControl();
     }
  }
//+------------------------------------------------------------------+
//|                刷新tick数据                                      |
//+------------------------------------------------------------------+
void CGridStudy01::RefreshTickData(void)
  {
   for(int i=0;i<num_symbols;i++)
      child_strategy[symbol_index[i]].RefreshTickPrice();
  }
//+------------------------------------------------------------------+
//|                刷新仓位信息                                      |
//+------------------------------------------------------------------+
void CGridStudy01::RefreshPositionState(void)
  {
// 刷新各个品种对的仓位信息
   for(int i=0;i<num_symbols;i++)
      child_strategy[symbol_index[i]].RefreshPositionState();
// 各个品种对的买卖手数矩阵赋值
   int counter_index=0;
   for(int i=0;i<8;i++)
     {
      for(int j=0;j<8;j++)
        {
         if(i>=j) continue;
         if(i<j)
           {
            int index=i*(15-i)/2+MathAbs(j-i)-1;
            if(counter_index>=num_symbols) break;  // 交易的品种数已经统计完毕
            if(index!=symbol_index[counter_index]) continue; // 该索引对应的品种不在指定的交易品种集合中
            symbol_lots[i].Set(j,child_strategy[index].pos_state.lots_buy);
            symbol_lots[j].Set(i,child_strategy[index].pos_state.lots_sell);
            counter_index++;
           }
        }
     }
// 计算每种货币的多空风险(多头手数-空头手数)
   for(int i=0;i<8;i++) currency_risk[i]=0;
   for(int i=0;i<8;i++)
     {
      for(int j=0;j<8;j++)
        {
         if(i==j) continue;
         currency_risk[i]+=symbol_lots[i][j];
         currency_risk[i]-=symbol_lots[j][i];
        }
     }
// 计算最强和最弱的货币
   for(int i=0;i<8;i++)
     {
      if(currency_risk[i]<currency_risk[index_short]) index_short=i;
      if(currency_risk[i]>currency_risk[index_long]) index_long=i;
     }
  }
//+------------------------------------------------------------------+
//|               进行平仓操作                                       |
//+------------------------------------------------------------------+
void CGridStudy01::CheckPositionClose(void)
  {
   for(int i=0;i<num_symbols;i++)
     {
      CGridSingleSymbol *s=&child_strategy[symbol_index[i]];
      if(s.pos_state.num_buy>0 && s.pos_state.profits_buy/s.pos_state.lots_buy>100)
         {
          s.CloseLongPosition(); // 平多头
          s.SetBaseLongLots(0.01);
         }
      if(s.pos_state.num_sell>0 && s.pos_state.profits_sell/s.pos_state.lots_sell>100)
         {
          s.CloseShortPosition(); // 平空头
          s.SetBaseShortLots(0.01);
         }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridStudy01::CheckPositionOpen(void)
  {
   for(int i=0;i<num_symbols;i++)
     {
      CGridSingleSymbol *s=&child_strategy[symbol_index[i]];
      if(s.pos_state.num_buy==0) s.BuildLongPosition(base_lots,0);  // 开多头首仓
      if(s.pos_state.num_sell==0) s.BuildShortPosition(base_lots,0);   // 开空头首仓
      if(s.pos_state.num_buy>0 && s.LastBuyPriceDown(300))
        {
         double lots_add=CalExpLots(s.pos_state.num_buy);
         s.AddLongPosition(lots_add,0);
        }
      if(s.pos_state.num_sell>0 && s.LastSellPriceUp(300))
        {
         double lots_add=CalExpLots(s.pos_state.num_sell);
         s.AddShortPosition(lots_add,0);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridStudy01::CheckPositionOpenUnderRiskControl(void)
  {
   if(IsEmptyPosition()) //空仓情况，首次建仓选择第一个品种对双向开仓
     {
      for(int i=0;i<num_symbols;i++)
        {
          CGridSingleSymbol *s=&child_strategy[symbol_index[i]];
         //s.BuildLongPosition(base_lots,0);
         //s.BuildShortPosition(base_lots,0);
         s.SetBaseLongLots(0.01);
         s.SetBaseShortLots(0.01);
         s.BuildLongPosition();
         s.BuildShortPosition();
        }
     
     }
   else // 持仓情况下--根据风险选择相关品种和方向进行开仓
     {
      // 对各个品种进行加仓判断
      for(int i=0;i<num_symbols;i++)
        {
         CGridSingleSymbol *s=&child_strategy[symbol_index[i]];
         //Print(s.ExpertSymbol(),": buy num:",s.pos_state.num_buy,", sell num:",s.pos_state.num_sell);
         if(s.pos_state.num_buy>0 && s.LastBuyPriceDown(300))
           {
            //double lots_add=CalExpLots(s.pos_state.num_buy+1);
            //s.AddLongPosition(lots_add,0);
            s.AddLongPosition();
           }
         if(s.pos_state.num_sell>0 && s.LastSellPriceUp(300))
           {
            //double lots_add=CalExpLots(s.pos_state.num_sell+1);
            //s.AddShortPosition(lots_add,0);
            s.AddShortPosition();
           }
         if(s.pos_state.num_buy==0) s.BuildLongPosition(base_lots,0);  // 开多头首仓
         if(s.pos_state.num_sell==0) s.BuildShortPosition(base_lots,0);   // 开空头首仓
           }
         // 根据风险情况，进行开仓对冲
         //OpenNewPositionByRiskControl1();
         OpenNewPositionByRiskControl2();
     }
  }
void CGridStudy01::OpenNewPositionByRiskControl2(void)
   {
    if(currency_risk[index_long]<0.04||currency_risk[index_short]>-0.04) return;
    
    if(index_long<index_short)
      {
       Print("改变手数:",currency_risk[index_long]," ", currency_risk[index_short]," ");
       int index=index_long*(15-index_long)/2+MathAbs(index_short-index_long)-1;
       CGridSingleSymbol *s=&child_strategy[index];
       s.SetBaseShortLots(MathMax(currency_risk[index_long]/2,0.01));
       if(s.pos_state.num_sell==0) s.BuildShortPosition();
      }
    //else
    //  {
    //   int index=index_short*(15-index_short)/2+MathAbs(index_short-index_long)-1;
    //   CGridSingleSymbol *s=&child_strategy[index];
    //   s.SetBaseLongLots(MathMax(currency_risk[index_long]/2,0.01));
    //  }
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridStudy01::OpenNewPositionByRiskControl1(void)
  {
   for(int i=0;i<8;i++) // 遍历货币风险值
     {
      if(currency_risk[i]==0) continue; // 已对冲无风险货币不进行操作
      if(currency_risk[i]>0.5) // 该币种有多头风险
        {
         int num_hedge=(int)(currency_risk[i]/base_lots);
         int counter_hedge=0;
         for(int j=i+1;j<8;j++) // 寻找对冲货币
           {
            int index=i*(15-i)/2+MathAbs(j-i)-1;
            for(int k=0;k<num_symbols;k++)
              {
               if(index==symbol_index[k]) // 对冲货币必须在事先指定的货币集合中
                 {
                  CGridSingleSymbol *s=&child_strategy[index];
                  if(s.pos_state.num_sell==0) // 该货币对还未进行卖空操作
                    {
                     //s.BuildShortPosition(base_lots,0);
                     s.SetBaseShortLots(0.01*2);
                     s.BuildShortPosition();
                     counter_hedge++;
                    }
                  if(counter_hedge>2) break;
                 }
              }
           }
        }
      else if(currency_risk[i]<-0.1) // 该币种有空头风险
        {
         int num_hedge=(int)(currency_risk[i]/base_lots);
         int counter_hedge=0;
         for(int j=i+1;j<8;j++) // 寻找对冲货币
           {
            int index=i*(15-i)/2+MathAbs(j-i)-1;
            for(int k=0;k<num_symbols;k++)
              {
               if(index==symbol_index[k]) // 对冲货币必须在事先指定的货币集合中
                 {
                  CGridSingleSymbol *s=&child_strategy[index];
                  if(s.pos_state.num_buy==0) // 该货币对还未进行买多操作
                    {
                     //s.BuildLongPosition(base_lots,0);
                     s.SetBaseLongLots(0.1*2);
                     s.BuildLongPosition();
                     counter_hedge++;
                    }
                  if(counter_hedge>2) break;
                 }
              }
           }
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CGridStudy01::CalExpLots(int index)
  {
   return NormalizeDouble(0.7*exp(0.4*index)*base_lots,2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGridStudy01::IsEmptyPosition(void)
  {
   for(int i=0;i<num_symbols;i++)
     {
      if(child_strategy[symbol_index[i]].IsEmptyPosition()==false) return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
