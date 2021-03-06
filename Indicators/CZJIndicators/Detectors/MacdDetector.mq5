//+------------------------------------------------------------------+
//|                                                 MacdDetector.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "chizhijing"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1

#property indicator_type1   DRAW_COLOR_ARROW
#property indicator_color1  clrBlue,clrRed,clrYellow
#property indicator_width1  2

input int                InpFastEMA=12;               // Fast EMA period
input int                InpSlowEMA=26;               // Slow EMA period
input int                InpSignalSMA=9;              // Signal SMA period
input ENUM_APPLIED_PRICE InpAppliedPrice=PRICE_CLOSE; // Applied price
input int                InpSearchBarNum=100;
input int                InpExtremeControlNum=2;

// Indicator buffers
double BuySell[];
double Color[];

int handle_macd;
double macd_buffer[];
datetime last_time=0;
string msg;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- indicator buffers mapping  
   SetIndexBuffer(0,BuySell,INDICATOR_DATA);
   SetIndexBuffer(1,Color,INDICATOR_COLOR_INDEX);

   ArraySetAsSeries(BuySell,true);
   ArraySetAsSeries(Color,true);

//---- drawing settings
   PlotIndexSetInteger(0,PLOT_ARROW,108);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetString(0,PLOT_LABEL,"MACD Detector");
   handle_macd=iMACD(NULL,_Period,InpFastEMA,InpSlowEMA,InpSignalSMA,InpAppliedPrice);
   Print("Init");
   SendNotification("Init");
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &tickvolume[],
                const long &volume[],
                const int &spread[])
  {
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(Open,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Close,true);
// 
   if(prev_calculated==0)
     {
      Print("首次计算");
      return BatchHandle(rates_total,time,Open,High,Low,Close,false);
     }

   bool is_new_bar=!(last_time==time[0]);
   if(!is_new_bar) return rates_total;
   Print("NewBar at time:",time[0]);
   last_time=time[0];
   
   BatchHandle(InpSearchBarNum+rates_total-prev_calculated,time,Open,High,Low,Close,true);
   
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int BatchHandle(const int num_handle,
                const datetime &time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                bool need_msg)
  {
   //if(need_msg)
   //  {
   //   SendNotification("hello");
   //  }
   if(CopyBuffer(handle_macd,0,0,num_handle,macd_buffer)<=0)
     {
      Print("复制MACD缓冲失败",GetLastError());
      return(0);
     }
   ArraySetAsSeries(macd_buffer,true);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(Open,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Close,true);
   for(int k=num_handle-InpSearchBarNum;k>=0;k--)
     {
      BuySell[k+1]=EMPTY_VALUE;
      //  寻找macd区域的起点
      int begin=k;
      for(int j=k+1;j<k+InpSearchBarNum;j++)
        {
         if(macd_buffer[j]*macd_buffer[k]<0)
           {
            begin=j-1;
            break;
           }
        }
      if(begin-k<10) continue;    //  macd的同一向的bar数太少，不进行识别
      
      if(macd_buffer[k]>0) // 寻找极大值
        {
         int index1=ArrayMaximum(macd_buffer,k+3,InpExtremeControlNum);
         if(macd_buffer[k+2]>=macd_buffer[index1] && macd_buffer[k+2]>macd_buffer[k+1])
           {
            for(int i=k+1+InpExtremeControlNum;i<begin;i++)
              {
               int index2=ArrayMaximum(macd_buffer,i+1,InpExtremeControlNum);
               int index3=ArrayMaximum(macd_buffer,i-InpExtremeControlNum,InpExtremeControlNum);
               if(macd_buffer[i]>=macd_buffer[index2] && macd_buffer[i]>=macd_buffer[index3])
                 {
                  if(High[k+2]>High[i] && macd_buffer[k+2]<macd_buffer[i])
                    {
                     msg="Sell背离=>Time:"+TimeToString(time[k])+" Location:2 to"+IntegerToString(i-k)+" 背离形态:"+DoubleToString(High[k+2],Digits())+"<"+DoubleToString(High[i],Digits())+","+DoubleToString(macd_buffer[k+2],4)+">"+DoubleToString(macd_buffer[i],4)+" 进场价格:"+DoubleToString(Close[k+1],Digits());
                     Print(msg);
                     BuySell[k+1]=Close[k+1];
                     Color[k+1]=0;
                     if(need_msg) SendNotification(msg);
                     break;
                    }
                  break;
                 }
              }
           }
        }
      else if(macd_buffer[k]<0)
        {
         int index1=ArrayMinimum(macd_buffer,k+3,InpExtremeControlNum);
         if(macd_buffer[k+2]<=macd_buffer[index1] && macd_buffer[k+2]<macd_buffer[k+1])
           {
            for(int i=k+1+InpExtremeControlNum;i<begin;i++)
              {
               int index2=ArrayMinimum(macd_buffer,i+1,InpExtremeControlNum);
               int index3=ArrayMinimum(macd_buffer,i-InpExtremeControlNum,InpExtremeControlNum);
               if(macd_buffer[i]<=macd_buffer[index2] && macd_buffer[i]<=macd_buffer[index3])
                 {
                  if(Low[k+2]<Low[i] && macd_buffer[k+2]>macd_buffer[i])
                    {
                     msg="Buy背离=>Time:"+TimeToString(time[k])+" Location:2 to"+IntegerToString(i-k)+" 背离形态:"+DoubleToString(Low[k+2],Digits())+">"+DoubleToString(Low[i],Digits())+","+DoubleToString(macd_buffer[k+2],4)+"<"+DoubleToString(macd_buffer[i],4)+",进场价格:"+DoubleToString(Close[k+1],Digits());
                     Print(msg);
                     BuySell[k+1]=Close[k+1];
                     Color[k+1]=1;
                     if(need_msg) SendNotification(msg);
                     break;
                    }
                  break;
                 }
              }
           }
        }
     }
   return(num_handle);
  }
//+------------------------------------------------------------------+
