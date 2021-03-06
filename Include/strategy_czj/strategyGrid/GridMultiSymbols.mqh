//+------------------------------------------------------------------+
//|                                             GridMultiSymbols.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#include <Strategy\Strategy.mqh>
#include "GridSingleSymbol.mqh"
#include "GridBaseOperate.mqh"
#include <Math\Alglib\matrix.mqh>
#include <Arrays\ArrayInt.mqh>

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
               if(symbol_strategy[index].pos_state.num_sell==0 && currency_risk[j]<0)
                 {
                  symbol_strategy[index].BuildShortPosition();
                  counter++;
                 }
              }
            if(i>j) // 做多symbol j&i
              {
               index=j*(15-j)/2+MathAbs(i-j)-1;
               if(symbol_strategy[index].pos_state.num_buy==0 && currency_risk[j]>0)
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

class CGridMultiSymbolsControl:public CStrategy
  {
private:
   CMatrixDouble     symbol_lots; // 上三角存储多单手数，下三角存储空单手数
   CMatrixDouble     dist_last_price; // 上三角存储与LastBuyPrice的距离，下三角存储与LastSellPrice的距离
   double            currency_risk[8];   // 存储每个币种的风险(多单手数-空单手数)
   bool              symbol_enabled[28]; // 品种对是否允许对冲交易的标志
   CArrayInt         risk_long_index;  // 多头风险对应品种的index
   CArrayInt         risk_short_index;  // 空头风险对应品种的index
   CArrayInt         no_risk_index; // 无风险品种对应index
   int               long_risk_max_index; //多头风险最大的品种对应的index
   int               short_risk_max_index; //空头风险最大的品种对应的index
   CArrayInt         symbol_grid_index;   // 允许进行正常网格交易的品种对

   CGridBaseOperate  grid_operator[28]; // 单个品种的策略
public:
                     CGridMultiSymbolsControl(void){};
                    ~CGridMultiSymbolsControl(void){};
   void              Init();
   virtual void      OnEvent(const MarketEvent &event);
protected:
   void              RefreshState();  // 刷新仓位信息     
   bool              IsEmptyPosition();   // 判断是否空仓   
   void              GridAddOperateNormal(); // 进行网格正常的加仓操作 
   void              GridAddOperateOpt(); // 基于风险优化的加仓操作
   void              GridHedgeOperate();  // 基于风险的网格对冲操作
   void              GridHedgeOperate2();  // 基于风险的网格对冲操作
   bool              HedgeSymbolOperate(int hedge_long_index, int hedge_short_index, int &r_counter);  // 根据给定的货币需要对冲的多空进行操作
   double            CalLotsFun(int num,int num_total,double base_lots); // 计算pos num_total为1手时，num对应的手数；
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridMultiSymbolsControl::Init(void)
  {
   for(int i=0;i<28;i++)
     {
      grid_operator[i].ExpertMagic(ExpertMagic()+i);
      grid_operator[i].ExpertSymbol(SYMBOLS_28[i]);
      symbol_enabled[i]=true;
     }
   symbol_lots.Resize(8,8);
   dist_last_price.Resize(8,8);
   symbol_grid_index.Add(19);
   //symbol_grid_index.Add(5);
   //symbol_grid_index.Add(13);
   //symbol_grid_index.Add(15);
   //symbol_grid_index.Add(17);
   
   //for(int i=0;i<28;i++)
   //  {
   //   symbol_enabled[i]=false;
   //  }
   //symbol_enabled[3]=true;
   //symbol_enabled[9]=true;
   //symbol_enabled[14]=true;
   //symbol_enabled[24]=true;
   //symbol_enabled[17]=true;

//   symbol_enabled[0]=false;
//   symbol_enabled[5]=false;
//   symbol_enabled[13]=false;
//   symbol_enabled[15]=false;
//   symbol_enabled[17]=false;
//   
//   symbol_enabled[7]=false;
//   symbol_enabled[8]=false;
//   symbol_enabled[10]=false;
//   symbol_enabled[11]=false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridMultiSymbolsControl::OnEvent(const MarketEvent &event)
  {
   if(event.symbol==ExpertSymbol() && event.type==MARKET_EVENT_BAR_OPEN)
     {
      RefreshState();
      GridAddOperateNormal(); // 对指定品种进行正常的网格交易
      //RefreshState();
      //GridAddOperateOpt(); // 根据风险对其他品种进行相关的对冲操作
      GridHedgeOperate2();
     }
  }
bool CGridMultiSymbolsControl::HedgeSymbolOperate(int hedge_long_index,int hedge_short_index, int &r_counter)
   {
    Print("hedge operate:", hedge_long_index, " ", hedge_short_index);
    int sym_index;
    r_counter=0;
    if(hedge_long_index<hedge_short_index) // currency[hedge_long_index]~currency[hedge_short_index] 做空对冲
      {
       sym_index=hedge_long_index*(15-hedge_long_index)/2+MathAbs(hedge_short_index-hedge_long_index)-1;
       if(!symbol_enabled[sym_index]) return false;   //不允许对冲交易的品种对，不进行对冲操作；
       if(grid_operator[sym_index].pos_state.num_sell==0)   // 对冲品种对未有空头仓位
         {
          if(grid_operator[sym_index].BuildShortPositionWithCostTP(200,0.01)) 
            {
             Print("对冲操作成功:short ",SYMBOLS_28[sym_index]," ,lots:",0.01);
             r_counter=1;
             return true;
            }
         }
       else if(grid_operator[sym_index].DistanceAtLastSellPrice()>200) 
         {
          double c_lots=CalLotsFun(grid_operator[sym_index].pos_state.num_sell+1,12,0.01);
          if(grid_operator[sym_index].BuildShortPositionWithCostTP(200,c_lots))
            {
             Print("对冲操作成功:short ",SYMBOLS_28[sym_index]," ,lots:",c_lots);
             r_counter=int(c_lots/0.01);
             return true;
            }
         }
      }
    else // currency[hedge_short_index]~currency[hedge_long_index] 做多对冲
      {
       sym_index=hedge_short_index*(15-hedge_short_index)/2+MathAbs(hedge_long_index-hedge_short_index)-1;
       if(!symbol_enabled[sym_index]) return false;   //不允许对冲交易的品种对，不进行对冲操作；
       if(grid_operator[sym_index].pos_state.num_buy==0)   // 对冲品种对未有多头仓位
         {
          if(grid_operator[sym_index].BuildLongPositionWithCostTP(200,0.01))
            {
             Print("对冲操作成功:long ",SYMBOLS_28[sym_index]," ,lots:",0.01);
             r_counter=1;
             return true;
            }
         }
       else if(grid_operator[sym_index].DistanceAtLastBuyPrice()>200) 
         {
          double c_lots=CalLotsFun(grid_operator[sym_index].pos_state.num_buy+1,12,0.01);
          if(grid_operator[sym_index].BuildLongPositionWithCostTP(200,c_lots))
            {
             Print("对冲操作成功:long ",SYMBOLS_28[sym_index]," ,lots:",c_lots);
             r_counter=int(c_lots/0.01); 
             return true;
            }
         }
      }
     return false;
   }
void CGridMultiSymbolsControl::GridHedgeOperate(void)
   {
    int long_hedge_total=int((currency_risk[long_risk_max_index]-0.05)/0.01);
    int short_hedge_total=int(-(currency_risk[short_risk_max_index]+0.05)/0.01);
    int long_counter=0,short_counter=0;
    int real_counter;

////    对冲多空最强的货币 
//Print("*************",long_risk_max_index," ", short_risk_max_index);   
//    if(HedgeSymbolOperate(long_risk_max_index,short_risk_max_index))
//      {
//       long_counter++;
//       short_counter++;
//      }
//    对冲多头风险最大的货币
    for(int i=0;i<risk_short_index.Total();i++)
      {
       if(long_counter>=long_hedge_total) break;
       if(HedgeSymbolOperate(long_risk_max_index,risk_short_index.At(i),real_counter))
         {
          long_counter++;
          RefreshState();
         }
       for(int j=0;j<risk_long_index.Total();j++)
         {
          HedgeSymbolOperate(risk_long_index.At(j),risk_short_index.At(i),real_counter);
         }
      }
//    对冲空头风险最大的货币
    for(int i=0;i<risk_long_index.Total();i++)
      {
       if(short_counter>=short_hedge_total) break;
       if(HedgeSymbolOperate(risk_long_index.At(i),short_risk_max_index,real_counter)) short_counter++;
       for(int j=0;j<risk_short_index.Total();j++)
         {
          HedgeSymbolOperate(risk_long_index.At(i),risk_short_index.At(j),real_counter);
         }
      }
   }
void CGridMultiSymbolsControl::GridHedgeOperate2(void)
   {
    RefreshState();
    bool is_hedged=risk_long_index.Total()==0&&risk_short_index.Total()==0;
    int hedge_num=0;
    while(!is_hedged&&hedge_num<10)
      {
       int long_hedge_total=int((currency_risk[long_risk_max_index]-0.05)/0.01);
       int short_hedge_total=int(-(currency_risk[short_risk_max_index]+0.05)/0.01);
       int long_counter=0,short_counter=0;
       int real_counter=0;
       //遍历空头风险货币，对冲多头风险最大的货币
       for(int i=0;i<risk_short_index.Total();i++)
         {
          Print("long hedge:",long_risk_max_index, " short currencies:",i, " in ", risk_short_index.Total());
          if(long_counter>=long_hedge_total) break;
          if(HedgeSymbolOperate(long_risk_max_index,risk_short_index.At(i),real_counter)) long_counter+=real_counter;
         }
       for(int i=0;i<no_risk_index.Total();i++)
         {
          Print("long hedge:",long_risk_max_index, " no risk currencies:",i, " in ", no_risk_index.Total());
          if(long_counter>=long_hedge_total) break;
          if(HedgeSymbolOperate(long_risk_max_index,no_risk_index.At(i),real_counter)) long_counter+=real_counter;
         }
      // 遍历多头风险货币，对冲空头风险最大的货币
       for(int i=0;i<risk_long_index.Total();i++)
         {
          if(short_counter>=short_hedge_total) break;
          Print("short hedge:",short_risk_max_index, " long currencies:",i, " in ", risk_long_index.Total());
          if(HedgeSymbolOperate(risk_long_index.At(i),short_risk_max_index,real_counter)) short_counter+=real_counter;
         }
        for(int i=0;i<no_risk_index.Total();i++)
         {
          if(short_counter>=short_hedge_total) break;
          Print("short hedge:",short_risk_max_index, " no risk currencies:",i, " in ", no_risk_index.Total());
          if(HedgeSymbolOperate(no_risk_index.At(i),short_risk_max_index,real_counter)) short_counter+=real_counter;
         }
        RefreshState();
        is_hedged=risk_long_index.Total()==0&&risk_short_index.Total()==0;
        hedge_num++;
      } 
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CGridMultiSymbolsControl::GridAddOperateOpt(void)
  {
   int symbol_index;
   for(int i=0;i<risk_long_index.Total();i++)
     {
      for(int j=0;j<risk_short_index.Total();j++)
        {
         if(risk_long_index[i]<risk_short_index[j]) // 品种对为i——j 多头风险
           {
            symbol_index=risk_long_index[i]*(15-risk_long_index[i])/2+MathAbs(risk_short_index[j]-risk_long_index[i])-1;
            if(grid_operator[symbol_index].pos_state.num_sell==0)
              {
               grid_operator[symbol_index].BuildShortPositionWithCostTP(200,0.01);
              }
            else if(grid_operator[symbol_index].DistanceAtLastSellPrice()>100)
              {
               grid_operator[symbol_index].BuildShortPositionWithCostTP(200,CalLotsFun(grid_operator[symbol_index].pos_state.num_sell+1,12,0.01));
              }
           }
         else // 品种对为j——i 空头风险
           {
            symbol_index=risk_short_index[j]*(15-risk_short_index[j])/2+MathAbs(risk_long_index[i]-risk_short_index[j])-1;
            if(grid_operator[symbol_index].pos_state.num_buy==0)
              {
               grid_operator[symbol_index].BuildLongPositionWithCostTP(200,0.01);
              }
            else if(grid_operator[symbol_index].DistanceAtLastBuyPrice()>100)
              {
               grid_operator[symbol_index].BuildLongPositionWithCostTP(200,CalLotsFun(grid_operator[symbol_index].pos_state.num_buy+1,12,0.01));
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CGridMultiSymbolsControl::CalLotsFun(int num,int num_total,double base_lots)
  {
   double beta=MathLog(100)/(num_total-1);
   double alpha=1/MathExp(beta);
   return NormalizeDouble(base_lots*alpha*exp(beta*num),2);
  }
//+------------------------------------------------------------------+
//|                正常网格交易的品种进行开仓和加仓操作              |
//+------------------------------------------------------------------+
void CGridMultiSymbolsControl::GridAddOperateNormal(void)
  {
   for(int j=0;j<symbol_grid_index.Total();j++)
     {
      int index_grid=symbol_grid_index.At(j);
      if(grid_operator[index_grid].pos_state.num_buy==0)
        {
         grid_operator[index_grid].BuildLongPositionWithCostTP(200,0.01);
        }
      else if(grid_operator[index_grid].DistanceAtLastBuyPrice()>250)
        {
         grid_operator[index_grid].BuildLongPositionWithCostTP(200,CalLotsFun(grid_operator[index_grid].pos_state.num_buy,12,0.01));
        }
      
      if(grid_operator[index_grid].pos_state.num_sell==0)
        {
         grid_operator[index_grid].BuildShortPositionWithCostTP(200,0.01);
        }
      else if(grid_operator[index_grid].DistanceAtLastSellPrice()>250)
        {
         grid_operator[index_grid].BuildShortPositionWithCostTP(200,CalLotsFun(grid_operator[index_grid].pos_state.num_sell,12,0.01));
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CGridMultiSymbolsControl::IsEmptyPosition(void)
  {
   for(int i=0;i<28;i++) if(!grid_operator[i].IsEmptyPosition()) return false;
   return true;
  }
//+------------------------------------------------------------------+
//|          刷新状态信息，tick报价，仓位信息，货币风险              |
//+------------------------------------------------------------------+
void CGridMultiSymbolsControl::RefreshState(void)
  {
   for(int i=0;i<28;i++)
     {
      grid_operator[i].RefreshTickPrice();  // 刷新tick报价
      grid_operator[i].RefreshPositionState(); // 刷新子策略各自的仓位信息
     }
   // 各个品种对的买卖手数矩阵赋值
   for(int i=0;i<8;i++)
     {
      for(int j=0;j<8;j++)
        {
         // 品种对多空手数矩阵赋值
         if(i>=j) continue;
         if(i<j)
           {
            int index=i*(15-i)/2+MathAbs(j-i)-1;
            symbol_lots[i].Set(j,grid_operator[index].pos_state.lots_buy);
            symbol_lots[j].Set(i,grid_operator[index].pos_state.lots_sell);
            dist_last_price[i].Set(j,grid_operator[index].DistanceAtLastBuyPrice());
            dist_last_price[j].Set(i,grid_operator[index].DistanceAtLastSellPrice());
           }
        }
     }
// 计算每种货币的多空风险(多头手数-空头手数)
   risk_long_index.Clear();
   risk_short_index.Clear();
   no_risk_index.Clear();
   for(int i=0;i<8;i++)
     {
      currency_risk[i]=0;  // 货币风险初始化0
      for(int j=0;j<8;j++)
        {
         if(i==j) continue;
         currency_risk[i]+=symbol_lots[i][j];
         currency_risk[i]-=symbol_lots[j][i];
        }
      if(currency_risk[i]>0.05) risk_long_index.Add(i);
      else if(currency_risk[i]<-0.05) risk_short_index.Add(i);
      else no_risk_index.Add(i);
      long_risk_max_index=ArrayMaximum(currency_risk);
      short_risk_max_index=ArrayMinimum(currency_risk);
     }
  }
//+------------------------------------------------------------------+
