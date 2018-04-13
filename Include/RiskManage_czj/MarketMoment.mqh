//+------------------------------------------------------------------+
//|                                                 MarketMoment.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Arrays\ArrayObj.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CurrenciesMoment
  {
private:
   ENUM_TIMEFRAMES period_moment;
   int            num_candles;
   string  currency_up[];
   string  currency_down[];
   string  symbol_buy[];
   string  symbol_sell[];
public:
                     CurrenciesMoment(ENUM_TIMEFRAMES period_moment_=PERIOD_M1,int num_candles_=5){period_moment=period_moment_;num_candles=num_candles_;};
                    ~CurrenciesMoment(void){};
int                 RefreshSymbolsMoments(string symbol,ENUM_TIMEFRAMES period, int num_candle);
void                GetCurrenciesMoments(string &xxx[], int &point[]);


  };

int CurrenciesMoment::RefreshSymbolsMoments(string symbol,ENUM_TIMEFRAMES period,int num_candle)
   {
    double high_price[],low_price[],current_price[];
    CopyHigh(symbol,period,1,num_candle,high_price);
    CopyLow(symbol,period,1,num_candle,low_price);
    CopyClose(symbol,period,0,1,current_price);
    int i_max = ArrayMaximum(high_price);
    int i_min = ArrayMinimum(low_price);
    int moment_points;
    if(current_price[0]<low_price[i_min])
       moment_points=(int)((current_price[0]-low_price[i_min])/SymbolInfoDouble(symbol,SYMBOL_POINT));
    else if(current_price[0]>high_price[i_max])
       moment_points=(int)((current_price[0]-high_price[i_max])/SymbolInfoDouble(symbol,SYMBOL_POINT));
    else moment_points=0;
    Print(moment_points);
    return moment_points;
   }
void CurrenciesMoment::GetCurrenciesMoments(string &xxx[], int &point[])
   {
   string currency[]={"USD","EUR","GBP","AUD","NZD","CAD","CHF","JPY"};
   string symbols[]={"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};
   int sign[]={1,1,1,1,-1,-1,-1};

   int points_matrix[8][8];
   for(int i=0;i<ArraySize(symbols);i++)
      points_matrix[0][i+1]=RefreshSymbolsMoments(symbols[i],period_moment,num_candles);
        
   for(int i=1;i<8;i++)
     {
      for(int j=0;j<8;j++)
        {
         if(i==j) continue;
         if(i<j) points_matrix[i][j]=points_matrix[0][i]-points_matrix[0][j];
         else points_matrix[i][j]=-points_matrix[j][i];
        }
     }
   int counter_up=0;
   int counter_down=0;
   for(int i=0;i<8;i++)
     {
      int sum_points=0;
      for(int j=0;j<8;j++)
        {
         if(i!=j) sum_points+=points_matrix[i][j];
        }
      points_matrix[i][i]=sum_points;
      point[i]=sum_points;
      if(point[i]>0)
        {
         counter_up++;
         ArrayResize(currency_up,counter_up);
         currency_up[counter_up-1]=currency[i];
        }
      else if((point[i]<0))
        {
         counter_down++;
         ArrayResize(currency_down,counter_down);
         currency_down[counter_down]=currency[i];
        }
     }
    //for(int i=0;i<8;i++)
    //  {
    //   Print(point[i]," ",EnumToString(period_moment),":",points_matrix[0][i],";");
    //  }
    ArrayCopy(xxx,currency);
   }