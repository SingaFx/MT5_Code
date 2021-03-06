//+------------------------------------------------------------------+
//|                                            SymbolCombination.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window

#property indicator_buffers 4
#property indicator_plots   4
#property indicator_type1   DRAW_LINE
#property indicator_color1  Red
#property indicator_width1  1
#property indicator_type2   DRAW_LINE
#property indicator_color2  Green
#property indicator_width2  1
#property indicator_type3   DRAW_LINE
#property indicator_color3  Yellow
#property indicator_width3  1
#property indicator_type4   DRAW_LINE
#property indicator_color4  Yellow
#property indicator_width4  1
#include <Math\Stat\Math.mqh> 
enum SymbolsCoefType
  {
   ENUM_SYMBOL_INPUT,
   ENUM_SYMBOL_PCA_F1,
   ENUM_SYMBOL_PCA_F2,
   ENUM_SYMBOL_PCA_F3,
   ENUM_SYMBOL_PCA_F4,
   ENUM_SYMBOL_PCA_F5,
   ENUM_SYMBOL_PCA_F6,
   ENUM_SYMBOL_PCA_F7
  };
  
input int Inp_Period=200;
input double Inp_delta=2.5;
input double Inp_Coef_EURUSD=1.0;
input double Inp_Coef_GBPUSD=1.0;
input double Inp_Coef_AUDUSD=1.0;
input double Inp_Coef_NZDUSD=1.0;
input double Inp_Coef_USDCAD=1.0;
input double Inp_Coef_USDCHF=1.0;
input double Inp_Coef_USDJPY=1.0;
input bool Inp_UseDefaultParameter=true;
input SymbolsCoefType Inp_CoefType=ENUM_SYMBOL_PCA_F1;


#define SYMBOLS_COUNT   7 // Number of symbols


double price_combination[];
double ma_price[];
double up_price[];
double down_price[];

string symbol_names[SYMBOLS_COUNT]={"EURUSD","GBPUSD","AUDUSD","NZDUSD","USDCAD","USDCHF","USDJPY"};
double symbol_coef[SYMBOLS_COUNT];
double points[SYMBOLS_COUNT];

double coef_default[]={-0.399507059528915,-0.370922865570124,-0.427589364667445,-0.181076685848670,0.503477240176153,0.104966594162066,0.471891501283697};
double coef_f1[]={-0.399507059528915,-0.370922865570124,-0.427589364667445,-0.181076685848670,0.503477240176153,0.104966594162066,0.471891501283697};
double coef_f2[]={0.156120119973915,0.715731392291141,-0.126736008372040,0.117875179050492,0.0299506048976982,-0.178609072735887,0.632929908423311};
double coef_f3[]={0.327979989020678,-0.516986378765809,0.201814258438518,0.527692590134551,0.0381730990152814,-0.452048047705465,0.316482422036138};
double coef_f4[]={0.307570633268989,0.146945928345138,-0.249584580981536,-0.171309807453575,0.589245072698589,-0.508662449132625,-0.431532668105931};
double coef_f5[]={0.743086948081259,-0.204609032796194,-0.395675619296499,-0.273858340231410,-0.188255687857085,0.350251237192899,0.127605689151442};
double coef_f6[]={0.0337389911317090,0.130386150934774,-0.311275182193609,0.743528195407073,0.254599822340319,0.458321993809418,-0.239279326649219};
double coef_f7[]={0.246035603007154,0.0491057587483893,0.666807638436350,-0.132957092001832,0.544688365174624,0.401573043778991,0.129610056992029};


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,price_combination,INDICATOR_DATA);
   SetIndexBuffer(1,ma_price,INDICATOR_DATA);
   SetIndexBuffer(2,up_price,INDICATOR_DATA);
   SetIndexBuffer(3,down_price,INDICATOR_DATA);
//---
   for(int i=0;i<SYMBOLS_COUNT;i++)
     {
         //--- add it to the Market Watch window and
      SymbolSelect(symbol_names[i],true);
      points[i]=SymbolInfoDouble(symbol_names[i],SYMBOL_POINT);
     }
    switch(Inp_CoefType)
      {
       case ENUM_SYMBOL_INPUT:
         symbol_coef[0]=Inp_Coef_EURUSD;
          symbol_coef[1]=Inp_Coef_GBPUSD;
          symbol_coef[2]=Inp_Coef_AUDUSD;
          symbol_coef[3]=Inp_Coef_NZDUSD;
          symbol_coef[4]=Inp_Coef_USDCAD;
          symbol_coef[5]=Inp_Coef_USDCHF;
          symbol_coef[6]=Inp_Coef_USDJPY;
         break;
       case ENUM_SYMBOL_PCA_F1:
          ArrayCopy(symbol_coef,coef_f1);
          break;
       case ENUM_SYMBOL_PCA_F2:
          ArrayCopy(symbol_coef,coef_f2);
          break;
       case ENUM_SYMBOL_PCA_F3:
          ArrayCopy(symbol_coef,coef_f3);
          break;
       case ENUM_SYMBOL_PCA_F4:
          ArrayCopy(symbol_coef,coef_f4);
          break;
       case ENUM_SYMBOL_PCA_F5:
          ArrayCopy(symbol_coef,coef_f5);
          break;
       case ENUM_SYMBOL_PCA_F6:
          ArrayCopy(symbol_coef,coef_f6);
          break;
       case ENUM_SYMBOL_PCA_F7:
          ArrayCopy(symbol_coef,coef_f7);
          break;
       default:
         break;
      }

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,      // 输入时间序列大小 
                 const int prev_calculated,  // 前一次调用处理的柱 
                 const datetime& time[],     // 时间 
                 const double& open[],       // 开盘价 
                 const double& high[],       // 最高价 
                 const double& low[],        // 最低价 
                 const double& close[],      // 收盘价 
                 const long& tick_volume[],  // 订单交易量 
                 const long& volume[],       // 真实交易量 
                 const int& spread[]         )
  {
//---
   int limit=0;
   double close_price[1];
      
   if(prev_calculated==0)
     {
      price_combination[0]=0;
      ma_price[0]=0;
      up_price[0]=0;
      down_price[0]=0;
      for(int i=1;i<rates_total;i++)
        {
         double price_sum=0;
         for(int j=0;j<SYMBOLS_COUNT;j++)
           {
            CopyClose(symbol_names[j],_Period,time[i],1,close_price);
            price_sum+=close_price[0]*symbol_coef[j]/points[j];
           }
          price_combination[i]=price_sum;
          if(i<Inp_Period)
           {
            ma_price[i]=0;
            up_price[i]=0;
            down_price[i]=0;
           }
          else
            {
             double temp_price[];
             ArrayCopy(temp_price,price_combination,0,i-Inp_Period,Inp_Period);
             double std=MathStandardDeviation(temp_price);
             ma_price[i]=MathMean(temp_price);
             up_price[i]=ma_price[i]+Inp_delta*std;
             down_price[i]=ma_price[i]-Inp_delta*std;
            }
        }
     }
   else
     {
      limit=prev_calculated-1;
     }
   for(int i=limit;i<rates_total;i++)
     {
      double price_sum=0;
      for(int j=0;j<SYMBOLS_COUNT;j++)
        {
         CopyClose(symbol_names[j],_Period,time[i],1,close_price);
         price_sum+=close_price[0]*symbol_coef[j]/points[j];
        }
      price_combination[i]=price_sum; 
      if(i<Inp_Period)
           {
            ma_price[i]=0;
            up_price[i]=0;
            down_price[i]=0;
           }
       else
         {
          double temp_price[];
          ArrayCopy(temp_price,price_combination,0,i-Inp_Period,Inp_Period);
          double std=MathStandardDeviation(temp_price);
          ma_price[i]=MathMean(temp_price);
          up_price[i]=ma_price[i]+Inp_delta*std;
          down_price[i]=ma_price[i]-Inp_delta*std;
         }
     }
   
   return rates_total;
  }
//+------------------------------------------------------------------+

