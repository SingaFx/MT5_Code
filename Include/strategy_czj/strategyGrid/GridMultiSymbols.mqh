//+------------------------------------------------------------------+
//|                                             GridMultiSymbols.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include "GridSingleSymbol.mqh"
#include <Math\Alglib\matrix.mqh>

string CURRENCIES[]={"EUR","GBP","AUD","NZD","USD","CAD","CHF","JPY"};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGridMultiSymbols:public CStrategy
  {
private:
   CMatrixDouble     symbol_lots; // 上三角存储多单手数，下三角存储空单手数
   double            currency_risk[8];   // 存储每个币种的风险(多单手数-空单手数)
   MqlTick           latest_price[28];  // 最近的Tick报价 
   CGridSingleSymbol symbol_strategy[28]; // 单个品种的策略

protected:
   void              RefreshPositionState();  // 刷新仓位信息
   bool              IsEmptyPosition(); // 当前是否空仓
   void              InitFirstPosition(); // 空仓状态建首仓
   void              ChildStrategyOperate();   // 子策略进行内部相关操作
   void              RiskHandle();  // 总策略风险处理

public:
                     CGridMultiSymbols(void);
                    ~CGridMultiSymbols(void){};
   virtual void      OnEvent(const MarketEvent &event);
  };
//+------------------------------------------------------------------+
//|              初始化操作                                          |
//+------------------------------------------------------------------+
CGridMultiSymbols::CGridMultiSymbols(void)
  {
   for(int i=0;i<28;i++)
     {
      // 子策略初始化操作
      symbol_strategy[i].ExpertMagic(i);
      symbol_strategy[i].ExpertSymbol(SYMBOLS_28[i]);
      // 组合策略初始化操作
      symbol_lots.Resize(8,8);
     }
  }
//+------------------------------------------------------------------+
//|                       子策略的处理                               |
//+------------------------------------------------------------------+
void CGridMultiSymbols::ChildStrategyOperate(void)
  {
   for(int i=0;i<28;i++)
     {
      if(symbol_strategy[i].IsEmptyPosition()==false) // 该子策略持仓的情况,进行加仓判断
        {
         if(symbol_strategy[i].AddLongPositionCondition())
           {
            Print("策略品种多头加仓:",symbol_strategy[i].ExpertSymbol());
            symbol_strategy[i].AddLongPosition();
            if(symbol_strategy[i].pos_state.num_sell==0)
              {
               symbol_strategy[i].BuildShortPosition();
              }
           }
         if(symbol_strategy[i].AddShortPositionCondition())
           {
            Print("策略品种空头加仓:",symbol_strategy[i].ExpertSymbol());
            symbol_strategy[i].AddShortPosition();
            if(symbol_strategy[i].pos_state.num_buy==0)
              {
               symbol_strategy[i].BuildLongPosition();
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                 总仓位的风险处理                                 |
//+------------------------------------------------------------------+
void CGridMultiSymbols::RiskHandle(void)
  {
   for(int i=0;i<8;i++)
     {
      if(currency_risk[i]==0) continue; // 该币种风险对冲完毕
      if(currency_risk[i]>0) // 该币种多头方向有风险
        {

         int counter=0;
         int num_hedge=(int)(currency_risk[i]/0.01); // 需要对冲的个数
         if(num_hedge<3) continue;
         //Print("币种多头方向有风险:",CURRENCIES[i],"需要对冲个数:",num_hedge);
         for(int j=0;j<8;j++) // 在该币种之前的货币，做多货币对对冲,在该币种之后的货币，做空对冲
           {
            int index;
            if(i==j) continue;
            if(i<j) //做空symbol i&j
              {
               index=i*(15-i)/2+MathAbs(j-i)-1;
               if(symbol_strategy[index].pos_state.num_sell==0&&currency_risk[j]<0)
                 {
                  symbol_strategy[index].BuildShortPosition();
                  counter++;
                 }
              }
            if(i>j) // 做多symbol j&i
              {
               index=j*(15-j)/2+MathAbs(i-j)-1;
               if(symbol_strategy[index].pos_state.num_buy==0&&currency_risk[j]>0)
                 {
                  symbol_strategy[index].BuildLongPosition();
                  counter++;
                 }

              }
            if(counter>num_hedge-3) break; // 对冲完毕
           }
        }
      else // 该币种空头方向有风险
        {
         int counter=0;
         int num_hedge=(int)(-currency_risk[i]/0.01); // 需要对冲的个数
         //Print("币种空头方向有风险:",CURRENCIES[i],"需要对冲个数:",num_hedge);
         if(num_hedge<3) continue;
         for(int j=0;j<8;j++) // 在该币种之前的货币，做空货币对对冲,在该币种之后的货币，做多对冲
           {
            int index=i*(15-i)/2+MathAbs(j-i)-1;
            if(i==j) continue;
            if(i<j) //做空symbol i&j
              {
               index=i*(15-i)/2+MathAbs(j-i)-1;
               if(symbol_strategy[index].pos_state.num_buy==0)
                 {
                  symbol_strategy[index].BuildLongPosition();
                  counter++;
                 }
              }
            if(i>j) // 做多symbol j&i
              {
               index=j*(15-j)/2+MathAbs(i-j)-1;
               if(symbol_strategy[index].pos_state.num_sell==0)
                 {
                  symbol_strategy[index].BuildShortPosition();
                  counter++;
                 }
              }
            if(counter>num_hedge-3) break; // 对冲完毕
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                    事件处理逻辑                                  |
//+------------------------------------------------------------------+
void CGridMultiSymbols::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_TICK)
     {
      for(int i=0;i<28;i++) symbol_strategy[i].RefreshTickPrice();   // 刷新子策略的tick报价
      RefreshPositionState();   // 刷新仓位信息
      if(IsEmptyPosition()) // 空仓情况建首仓
        {
         Print("空仓情况，首次建仓");
         InitFirstPosition();
        }
      else // 持仓情况--1.每个子策略品种的操作，2.风险判断和措施
        {
         ChildStrategyOperate();
         RefreshPositionState();
         RiskHandle();
        }
     }
  }
//+------------------------------------------------------------------+
//|             刷新仓位信息--子策略仓位信息，品种矩阵，货币风险     |
//+------------------------------------------------------------------+
void CGridMultiSymbols::RefreshPositionState(void)
  {
// 刷新子策略的仓位信息
   for(int i=0;i<28;i++) symbol_strategy[i].RefreshPositionState();
// 各个品种对的买卖手数矩阵赋值
   for(int i=0;i<8;i++)
     {
      for(int j=0;j<8;j++)
        {
         if(i>=j) continue;
         if(i<j)
           {
            int index=i*(15-i)/2+MathAbs(j-i)-1;
            symbol_lots[i].Set(j,symbol_strategy[index].pos_state.lots_buy);
            symbol_lots[j].Set(i,symbol_strategy[index].pos_state.lots_sell);
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
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGridMultiSymbols::IsEmptyPosition(void)
  {
   for(int i=0;i<28;i++)
     {
      if(symbol_strategy[i].IsEmptyPosition()==false) return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridMultiSymbols::InitFirstPosition(void)
  {
//for(int i=0;i<28;i++)
//  {
//   symbol_strategy[i].BuildLongPosition();
//   symbol_strategy[i].BuildShortPosition();
//  }
   symbol_strategy[0].BuildLongPosition();
   symbol_strategy[0].BuildShortPosition();
  }
//+------------------------------------------------------------------+
