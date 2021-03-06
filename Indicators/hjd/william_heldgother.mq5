//+------------------------------------------------------------------+
//|                                                         wave.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+


#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_LINE
#property indicator_color1  DodgerBlue
#property indicator_label1  "william"
//*
#property indicator_type2   DRAW_NONE
#property indicator_color2  DodgerBlue
#property indicator_label2  "difprice"
//*/
//--- indicator buffers
double   theprice[];

double   newhigh[];
double   newlow[];
double   william[];

string   nextsymbol;
bool needfresh=true;
int win; 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//斐波那契数列:1,1,2,3,5,8,13,21,34,55,89,144,233,377,610,
//1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233,377,610,987,1597,2584,4181,6765,10946,17711,28657,46368
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
//13天 = 78*4小时 = 312 小时 = 624 * 30min = 1248 * 15min = 3744 * 5min = 6240 * 3min =  9360 * 2min = 18720 min
//13     89         377        610           1597           4181          6765           10946         17711

//DAY			13			13			8			8			5		5			3		3
//4HOURS		78			89			48			55			30		34			18		21
//HOUR		312		377		192		233		120	144		72		89
//30MINS		624		610		384		377		240	233		144	144
//15MIN		1248		1597		768		610		480	377		288	233
//5Min		3744		4181		2304		2584		1440	1597		964	987
//1Min		18720		17711		11520		10946		7200	6765		4320	4181
//

enum CORRELATION{COR_POSITIVE,COR_NEGATIVE,COR_DIFF};  //正相关，价差使用对数差；负相关，价差使用对数和；价格差，价格直接求差
enum BAIS_MODE{BM_CLOSE,BM_EMA};
input double thewin = 0.5;//周期的天数
input string symbol1="XAUUSD" ; //品种1
input string symbol2="USDJPY";  //品种2
input double hourinday1=23; //品种1的一天交易时长
input double hourinday2=24; //品种2的一天交易时长
input CORRELATION m_correlation = COR_NEGATIVE;
input double offset = 12 ;  //为确保价差>0,并且尽可能消除品种对的差异性
double barinoneday;
input double max_value1 = FLT_MAX;
input double min_value1 = 0;
input double max_value2 = FLT_MAX;
input double min_value2 = 0;

int para1[] = {13,89,377,610,1597,4181,17711};
int para2[] = {8,48,192,384,768,2304,11520};
int para3[] = {5,34,144,233,377,1597,6765};
int para4[] = {3,18,69,138,276,828,4140};
int para[] ;
//string symbol1 ="USDJPY";
//string symbol2 ="GBPUSD";
int OnInit()
  {
  //ArrayCopy(para,para4);
  //Print("helloadsfdads111");
   

   if(StringCompare(Symbol(),symbol1)==0)
   {
      switch(Period())
      {
      case PERIOD_M1:win = int(thewin*hourinday1*60); break;
      case PERIOD_M5:win = int(thewin*hourinday1*12);break;
      case PERIOD_M15:win = int(thewin*hourinday1*4);break;
      case PERIOD_M30:win = int(thewin*hourinday1*2);break;
      case PERIOD_H1:win = int(thewin*hourinday1);break;
      case PERIOD_H4:win = int(thewin*6);break;
      case PERIOD_D1:win = int(thewin);break;
      default:Alert("不支持的周期：",Period());return (INIT_FAILED);

      }
      nextsymbol=symbol2;
   }
   else if(StringCompare(Symbol(),symbol2)==0)
   {
      switch(Period())
      {
      case PERIOD_M1:win = int(thewin*hourinday2*60); break;
      case PERIOD_M5:win = int(thewin*hourinday2*12);break;
      case PERIOD_M15:win = int(thewin*hourinday2*4);break;
      case PERIOD_M30:win = int(thewin*hourinday2*2);;break;
      case PERIOD_H1:win = int(thewin*hourinday2);break;
      case PERIOD_H4:win = int(thewin*6);break;
      case PERIOD_D1:win = int(thewin);break;
      default:Alert("不支持的周期：",Period());return (INIT_FAILED);

      }
      nextsymbol=symbol1;
   }
   else
     {
      Print("wrong symbol1:",Symbol());
      needfresh=false;
      return(INIT_FAILED);
     }

   SetIndexBuffer(0,william,INDICATOR_DATA);
   SetIndexBuffer(1,theprice,INDICATOR_DATA);
   //SetIndexBuffer(2,newhigh,INDICATOR_CALCULATIONS);
   //SetIndexBuffer(3,newlow,INDICATOR_CALCULATIONS);

//--- indicator buffers mapping
	bool synchronized=false;
      //--- 循环计数器
   int attempts=0;
      // 进行5次尝试等候同步进行
   while(attempts<5)
   {
      if(SeriesInfoInteger(nextsymbol,Period(),SERIES_SYNCHRONIZED))
      {
            //--- 同步化完成，退出
         synchronized=true;
         break;
      }
         //--- 增加计数器
      attempts++;
         //--- 等候10毫秒直至嵌套反复
      Sleep(10);
   }
      //--- 同步化后退出循环
   if(synchronized)
   {
      
      Print("The first date in the terminal history for the symbol-period at the moment = ",
            (datetime)SeriesInfoInteger(nextsymbol,0,SERIES_FIRSTDATE));
      Print("The first date in the history for the symbol on the server = ",
            (datetime)SeriesInfoInteger(nextsymbol,0,SERIES_SERVER_FIRSTDATE));
   }
      //--- 不发生数据同步
   else
   {
      Print("Failed to get number of bars for ",nextsymbol);
      //如果这这里同步不了的话，那么就继续让程序跑，获不到bar的情况下，他会再做一次同步
      //return(INIT_FAILED);
   }

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   static double max_latest = -DBL_MAX;
   static double min_latest = DBL_MAX;   
   static bool isbusy = false;
   if(prev_calculated>rates_total)
   	return 0;
   if(rates_total>0)
   	william[rates_total - 1] = 0;
   if(rates_total < win  || rates_total < prev_calculated) //数据不够
   	return 0;
   
   if(isbusy)
   {
   	Print("is busy");
    	return prev_calculated;
   } 	   
   isbusy = true;
	
   static int nextpos=0;
   uint timestart;
   if(prev_calculated == 0) 
   {
   	nextpos = 0;//prev_calculated ==0 有三种情况，初次计算，出现错误需要重新计算，人工刷新导致重新计算
   	timestart = GetTickCount();
   	ArrayInitialize(william,0);//设置为异常
   }
   int nextbars=Bars(nextsymbol,Period());
   if(nextbars<1)
   {
   	SeriesInfoInteger(nextsymbol,Period(),SERIES_SYNCHRONIZED);
   	isbusy = false;
   	return prev_calculated;
   }
   int start=MathMax(0,prev_calculated-1); //
   start = MathMax(start,rates_total - win -50000);
   MqlRates nextrates[];
   int datalen=CopyRates(nextsymbol,Period(),time[start],time[rates_total-1],nextrates);
   if(datalen<0)
     {
   	isbusy = false;
      return prev_calculated;
     }
   int j=0,findj = 0;
   for(int i=start;i<rates_total;i++)
     {
     	
      for(;j<datalen;j++)
        {
         //有三种情况，time1 > time2,time1<time2,time1=time2;
         if(time[i]>nextrates[j].time)continue;   // time1 > time2，继续寻找下一个time2
                                                  //if(time[i] < nextrates[j].time) break;     // time1 < time2,继续寻找下一个time1,跳出这个循环后，continue下一个循环
         break;
         //time1 < time2 和time1 = time2 都是直接跳出
        }
      if(j>=datalen || time[i]<nextrates[j].time)
        {//找到最后都没有找到与当前bar对应的bar,也就是当前bar的时间要比对应品种的最新时间还要新，说明这个bar时间及之后对应品种都没有交易，直接跟新所有的
         //j++;
         if(i==0)
            theprice[i]=0;
         else
         {
         	theprice[i]=theprice[i-1];   
         }
         
         
        }
      else
      {
      //剩下就是time1 = time2的情况了
      	if(close[i] <= min_value1 || close[i] >= max_value1 || nextrates[j].close <= min_value2 || nextrates[j].close >= max_value2) // 异常的bar线，有问题
      	{
      		PrintFormat("theprice is wrong!!!! close1 = %f, close2 = %f",close[i],nextrates[j].close);
   			isbusy = false;
      		william[i] = 0;
      		return i + 1;
      	}
      	else if((i && (close[i-1]/close[i] > 5 || close[i-1]/close[i] < 0.2 ))  || 
      	        (j && (nextrates[j-1].close/nextrates[j].close > 5 || nextrates[j-1].close/nextrates[j].close <0.2 )))
      	{
      		isbusy = false;
      		william[i] = 0;
      		return i ;
      	}
      	switch(m_correlation)
         {
            case COR_POSITIVE: theprice[i]=log(close[i]/nextrates[j].close)+offset;break;
            case COR_NEGATIVE: theprice[i]=log(close[i]*nextrates[j].close)+offset;break;
            case COR_DIFF   : theprice[i]=close[i]-nextrates[j].close+offset;break;
         }
        	findj = j;
         j++;
      }      
      if(i>=win-1 && i > rates_total -50000)
      {
         double max_fact ,min_fact; 
         //int maxind,minind;
         if(start == rates_total-1) //在只有一根bar的时候，不用每次都计算全数据,可以有效提升效率
         {
            max_fact = MathMax(max_latest,theprice[i]);
            min_fact = MathMin(min_latest,theprice[i]);
         
         }
         else
         {
            //int maxind = ArrayMaximum(theprice,i-win+1,win);
            //int minind = ArrayMinimum(theprice,i-win+1,win);
            max_fact = max_latest = MathMax(theprice[ArrayMaximum(theprice,i-win+1,win-1)],theprice[i]);
            min_fact = min_latest = MathMin(theprice[ArrayMinimum(theprice,i-win+1,win-1)],theprice[i]);
      	}
      	if(max_fact==min_fact)
      	{
      			william[i] = william[i-1];
      			
      	}
      	else
      	{
      		
      		william[i] = (theprice[i]-min_fact)/(max_fact-min_fact)+1;
      		
      	}
      }
      else
      {
      	william[i] = 0;
      	
      }
      
      
     } 	

   if(prev_calculated==0)
     {

      //将结果写入文件

     }
	if(prev_calculated ==0)
	{
		Print("Time: ",GetTickCount()-timestart," last william=",william[rates_total-2],"  lasttime:",time[rates_total-2]);
	}
//---

//--- return value of prev_calculated for next call
	isbusy = false;
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---

  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---

  }
//+------------------------------------------------------------------+

double StdDev_Func(int position,const double &price[],const double &MAprice[],int period)
  {
//--- variables
   double StdDev_dTmp=0.0;
//--- check for position
   if(position<period) return(StdDev_dTmp);
//--- calcualte StdDev
   for(int i=0;i<period;i++) StdDev_dTmp+=MathPow(price[position-i]-MAprice[position],2);
   StdDev_dTmp=MathSqrt(StdDev_dTmp/period);
//--- return calculated value
   return(StdDev_dTmp);
  }
//+------------------------------------------------------------------+
